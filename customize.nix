{ pkgs, config, ...}:
{

  networking = {
    domain = "itpartner.intern";
    search = [ "itpartner.intern" "itpartner.no" ];
  };

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKiAS30ZO+wgfAqDE9Y7VhRunn2QszPHA5voUwo+fGOf jonas-3"
  ];

  customize = {
    desktop.enable = false;

    boot = {
      uefi = true;
      device = "/dev/sda";
    };

    kernelExtras = false;

    externalInterface = "eno1";

    virtualisation = {
      docker = true;
      libvirt = false;
    };

    lan.enable = false;

    dnsmasq.enable = true;
    dnsmasq.extraConfig = ''
      address=/.cluster.local/10.101.0.1
    '';
  };
}

