{ pkgs, config, ... }:
with pkgs;
let
  cfg = config.feature.pki;

  certName = attr: {
    CN = "${attr.name}";
    O = "${attr.o}";
    OU = "${attr.name}.pki.caSpec";
    L = "certmgr";
  };

  ca_csr = pkgs.writeText "${cfg.name}-csr.json" (builtins.toJSON {
      CN = "${cfg.name}";
      key = {
        algo = cfg.algo;
        size = if cfg.algo == "ecdsa" then 256 else 2048;
      };
      names = [ certName cfg ];
    }
  );

  # make ca derivation sha depend on initca cfssl output
  initca = pkgs.stdenv.mkDerivation {
    inherit name;
    src =
      if cfg.ca != null then
        cfg.ca
      else
        pkgs.runCommand "initca" { buildInputs = [ pkgs.cfssl ]; } ''
          cfssl genkey -initca ${ca_csr} | cfssljson -bare ca;
          mkdir -p $out; cp *.pem $out
        '';
    buildCommand = ''
      mkdir -p $out;
      cp -r $src/* $out
    '';
  };

  ca = {
    key = "${initca}/ca-key.pem";
    cert = "${initca}/ca.pem";
  };

  ca-config = pkgs.writeText "ca-config.json" ''
    {
      "signing": {
         "default": {
            "expiry": "8760h"
          },
          "profiles": {
             "default": {
                "usages": [
                   "signing",
                   "key encipherment",
                   "server auth",
                   "client auth"
                 ],
                 "expiry": "8760h"
             }
          }
       }
    }
  '';

  gencsr = args:
    let
      csr = {
        CN = "${args.cn}";
        key = {
          algo = cfg.algo;
          size = if cfg.algo == "ecdsa" then 256 else 2048;
        };
        names = [ certName args ];
        hosts = args.hosts;
      };
    in
      pkgs.writeText "${args.cn}-csr.json" (builtins.toJSON csr);

  # Example usage:
  # gencert { cn = "test"; ca = ca; o = "test; };
  gencert = cn: attrs:
    let
      conf = {
        inherit ca cn;
        csr = gencsr { cn = cn; hosts = attrs.hosts; };
      };
      cfssl = conf:
        ''
          cfssl gencert -ca ${ca.cert} -ca-key ${ca.key} \
          -config=${ca-config} -profile=default ${conf.csr} | \
          cfssljson -bare cert; \
          mkdir -p $out; cp *.pem $out
        '';
      crt =
        pkgs.runCommand "${cn}" {
          buildInputs = [ pkgs.cfssl ];
        } (cfssl conf);
    in
    {
      key = "${crt}/cert-key.pem";
      cert = "${crt}/cert.pem";
    };

  certmgr = {
    services.certmgr = {
      enable = true;
      package = pkgs.certmgr-selfsigned;
      svcManager = "systemd";
      specs =
        let
          secret = name: "/var/lib/secrets/${name}.pem";
          mkSpec = name: cert: {
            service = name;
            action = "reload";
            authority = { file.path = ca.cert; };
            certificate = {
              path = secret name;
            };
            private_key = {
              owner = "root";
              group = "root";
              mode = "0600";
              path = secret "${name}-key";
            };
            request = {
              CN = name;
              hosts = [ name ] ++ cert.hosts;
              key = { algo = "rsa"; size = 2048; };
              names = certName cfg;
            };
          };
        in
        mapAttrs mkSpec cfg.certs;
    };
  };

  gencerts = {
     x = mapAttrs gencert cfg.certs;
  };

  configuration = {
    security.pki.certificateFiles = [ ca.cert ];
  };
in {
  options.feature.pki = {
    enable = mkEnableOption "Enable default system packages";

    ca = mkOption {
      type = types.path;
      default = null;
      description = "Path to ca certificate to use as Root CA.";
    };

    algo = mkOption {
      type = types.string;
      default = "rsa";
    };

    name = mkOption {
      type = types.string;
      default = "ca";
    };

    o = mkOption {
      type = types.string;
      default = "NixOS";
    };

    certs = mkOption {
      type =type.attrsOf type.attrs;
      default = {};
      example = { "example.local" = { hosts = []; }; };
    };

    certmgr = {
      enable = mkEnableOption "Enable certmgr";
      domain = mkOption {
        type = types.string;
        default = "local";
      };
    };

    static.enable = mkEnableOption "Generate static cert derivations";
  };

  config = mkMerge [
    (mkIf cfg.enable configuration)

    (mkIf (cfg.enable && cfg.certmgr.enable) certmgr)

    (mkIf (cfg.enable && cfg.static.enable) gencerts)
  ];
}

