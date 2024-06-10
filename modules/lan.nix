{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.features.lan;

  configuration = {
    services.cntlm.netbios_hostname = config.networking.hostName;

    services.samba = {
      enable = true;
      enableNmbd = true;
      nsswins = true;
      extraConfig = cfg.samba.extraConfig;
    };

    networking.firewall = {
      allowedTCPPorts = [ 139 445 ];
      allowedUDPPorts = [ 137 138 ];
    };

    security.krb5 = {
      enable = cfg.krb5.enable;
      settings = {
        libdefaults = {
          default_realm = cfg.krb5.default_realm;
        };
        domain_realm = cfg.krb5.domain_realm;
        realms = cfg.krb5.realms;
      };
    };

    # Ugly hack because of hard coded kernel path
    system.activationScripts.symlink-requestkey = ''
      if [ ! -d /sbin ]; then
        mkdir /sbin
      fi
      ln -sfn /run/current-system/sw/bin/request-key /sbin/request-key
    '';

    environment.systemPackages = [ pkgs.krb5 ];

    # request-key expects a configuration file under /etc
    environment.etc."request-key.conf" = {
      text = let
        upcall = "${pkgs.cifs-utils}/bin/cifs.upcall";
        keyctl = "${pkgs.keyutils}/bin/keyctl";
      in ''
        #OP     TYPE          DESCRIPTION  CALLOUT_INFO  PROGRAM
        # -t is required for DFS share servers...
        create  cifs.spnego   *            *             ${upcall} -t %k
        create  dns_resolver  *            *             ${upcall} %k
        # Everything below this point is essentially the default configuration,
        # modified minimally to work under NixOS. Notably, it provides debug
        # logging.
        create  user          debug:*      negate        ${keyctl} negate %k 30 %S
        create  user          debug:*      rejected      ${keyctl} reject %k 30 %c %S
        create  user          debug:*      expired       ${keyctl} reject %k 30 %c %S
        create  user          debug:*      revoked       ${keyctl} reject %k 30 %c %S
        create  user          debug:loop:* *             |${pkgs.coreutils}/bin/cat
        create  user          debug:*      *             ${pkgs.keyutils}/share/keyutils/request-key-debug.sh %k %d %c %S
        negate  *             *            *             ${keyctl} negate %k 30 %S
      '';
    };
  };
in
  {
    options.features.lan = {
      enable = mkEnableOption "Enable LAN configs";

      domain = mkOption {
        type = types.str;
        default = "";
      };

      domainSearch = mkOption {
        type = types.listOf types.str;
        default = [ cfg.lan.domain ];
      };

      samba.extraConfig = mkOption {
        type = types.str;
        default = "";
      };

      krb5 = {
        enable = mkEnableOption "Enable Kerberos";

        default_realm = mkOption {
          type = types.str;
          default = "";
        };

        domain_realm = mkOption {
          type = types.attrs;
          default = {};
        };

        realms = mkOption {
          type = types.attrs;
          default = {};
        };
      };
    };

  config = mkMerge [
    (mkIf cfg.enable configuration)
  ];
}
