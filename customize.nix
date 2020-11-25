{ pkgs, config, ...}:
{

  networking = {
    hostName = "nixos";
    domain = "local";
    search = [ "local" ];
  };

  services.dnsmasq.enable = false;

  services.dnsmasq.extraConfig = ''
      address=/.test.local/10.0.0.1
  '';

  users.extraUsers.root.openssh.authorizedKeys.keys = [];

  customize = {
    desktop.enable = false;

    boot = {
      uefi = true;
      device = "/dev/sda";
    };

    kernelExtras = false;

    externalInterface = "eno2";

    virtualisation = {
      docker = true;
      libvirt = false;
    };

    lan = {
      enable = false;

      samba.extraConfig = ''
        netbios name = ${config.networking.hostName}
        workgroup = WORKGROUP
        # add machine script = /run/current-system/sw/bin/useradd -d /var/empty -g 65534 -s /run/current-system/sw/bin/false -M %u
      '';

      krb5 = {
        enable = false;
        default_realm = "LOCAL";

        domain_realm = {
          "local" = "LOCAL";
          ".local" = "LOCAL";
        };

        realms = {
          "LOCAL" = {
            admin_server = "dc.local";
            kdc = "dc.local";
          };
        };
      };
    };
  };
}

