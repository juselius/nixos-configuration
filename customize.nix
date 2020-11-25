{ pkgs, config, ...}:
{
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

    hpc.slurm = {
      server = true;
      controlMachine = "regnekraft";
      nodeName = [
        "DEFAULT CPUs=1 RealMemory=196000 TmpDisk=250000 State=UNKNOWN"
        "c0-[1-8] NodeAddr=c0-[1-8]"
      ];
      partitionName = [
        "run Nodes=c0-[1-8] Default=YES MaxTime=INFINITE State=UP"
      ];
      storagePass  = "olj2jememd";
    };
  };

  networking = {
    hostName = "regnekraft";
    domain = "itpartner.intern";
    search = [ "itpartner.intern" "itpartner.no" ];
  };

  services.dnsmasq.enable = true;
  services.dnsmasq.extraConfig = ''
      address=/.cluster.local/10.101.0.1
    '';

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKiAS30ZO+wgfAqDE9Y7VhRunn2QszPHA5voUwo+fGOf jonas-3"
  ];
}

