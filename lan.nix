{ hostName, pkgs, ... }:
{
  networking.search = [];

  services.dnsmasq = {
    enable = true;
    extraConfig = ''
      address=/.local/10.0.0.1
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [ 139 445 ];
    allowedUDPPorts = [ 137 138 ];
  };

  services.cntlm.netbios_hostname = hostName;
  services.samba = {
    enable = false;
    enableNmbd = true;
    nsswins = true;
    extraConfig = ''
      netbios name = ${hostName}
      workgroup = WORKGROUP
      # add machine script = /run/current-system/sw/bin/useradd -d /var/empty -g 65534 -s /run/current-system/sw/bin/false -M %u
    '';
  };

  krb5 = {
    enable = true;
    libdefaults = {
      default_realm = "WORKGROUP";
    };
    domain_realm = {
      "local" = "WORKGROUP";
      ".local" = "WORKGROUP";
    };
    realms = {
        "WORKGROUP.INTERN" = {
          admin_server = "dc1.local";
          kdc = "dc1.local";
        };
    };
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
