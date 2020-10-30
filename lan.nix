{ pkgs, config, ... }:
let
  cfg = config.customize;
in
{
  services.cntlm.netbios_hostname = config.networking.hostName;

  services.samba = {
    enable = true;
    enableNmbd = true;
    nsswins = true;
    extraConfig = cfg.lan.samba.extraConfig;
  };

  services.dnsmasq = {
    enable = true;
    extraConfig = cfg.lan.dnsmasq.extraConfig;
  };

  networking.firewall = {
    allowedTCPPorts = [ 139 445 ];
    allowedUDPPorts = [ 137 138 ];
  };

  krb5 = {
    enable = false;
    libdefaults = {
      default_realm = cfg.lan.krb5.default_realm;
    };
    domain_realm = cfg.lan.krb5.domain_realm;
    realms = cfg.lan.krb5.realms;
  };

  # Ugly hack because of hard coded kernel path
  system.activationScripts.symlink-requestkey = ''
      if [ ! -d /sbin ]; then
        mkdir /sbin
      fi
      ln -sfn /run/current-system/sw/bin/request-key /sbin/request-key
  '';

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

}
