{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.features.pki;

  certName = attrs: {
    CN = "${attrs.name}";
    O = "${attrs.o}";
    OU = "${attrs.name}.pki.caSpec";
    L = "certmgr";
  };

  ca_csr = pkgs.writeText "${cfg.name}-csr.json" (builtins.toJSON {
      CN = "${cfg.name}";
      key = {
        algo = cfg.algo;
        size = if cfg.algo == "ecdsa" then 256 else 2048;
      };
      names = [ (certName cfg) ];
    }
  );

  # make ca derivation sha depend on initca cfssl output
  initca = pkgs.stdenv.mkDerivation {
    name = cfg.name;
    src =
      if cfg.ca != ./. then
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
        names = [ (certName args) ];
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
    in
      pkgs.runCommand "${cn}" {
        buildInputs = [ pkgs.cfssl ];
      } (cfssl conf);

  certmgr = {
    services.certmgr = {
      enable = true;
      package = pkgs.certmgr-selfsigned;
      svcManager = "command";
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

  # gencerts = {
  #    mapAttrs gencert cfg.certs;
  # };

  configuration = {
    security.pki.certificateFiles = [ ca.cert ];
  };
in {
  options.features.pki = {
    enable = mkEnableOption "Enable default system packages";

    ca = mkOption {
      type = types.path;
      default = ./.;
      description = "Path to ca certificate to use as Root CA.";
    };

    algo = mkOption {
      type = types.str;
      default = "rsa";
    };

    name = mkOption {
      type = types.str;
      default = "ca";
    };

    o = mkOption {
      type = types.str;
      default = "NixOS";
    };

    certs = mkOption {
      type = types.attrsOf types.attrs;
      default = {};
      example = { "example.local" = { hosts = []; }; };
    };

    certmgr = {
      enable = mkEnableOption "Enable certmgr";

      domain = mkOption {
        type = types.str;
        default = "local";
      };
    };

    static.enable = mkEnableOption "Generate static cert derivations";
  };

  config = mkMerge [
    (mkIf cfg.enable configuration)

    (mkIf (cfg.enable && cfg.certmgr.enable) certmgr)

    # (mkIf (cfg.enable && cfg.static.enable) gencerts)
  ];
}

