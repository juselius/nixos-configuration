{ pkgs, config, ...}:
{
  networking = {
    hostName = "vortex";
    domain = "itpartner.intern";
    search = [ "itpartner.intern" "itpartner.no" ];
    firewall = {
      allowedTCPPorts = [ 80 443 6817 6818 6819 ];
      allowedUDPPorts = [ ];
    };
  };

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

    hpc.prometheusServer = true;
    hpc.prometheusExporter = true;

    hpc.mungeKey = ./munge.key;

    hpc.slurm = {
      server = true;
      controlMachine = "vortex";
      nodeName = [
        "c0-[1-8] CPUs=64 RealMemory=196000 TmpDisk=250000 State=UNKNOWN"
        "yoneda  CPUs=12 Sockets=1 CoresPerSocket=6 ThreadsPerCore=2 RealMemory=8000 TmpDisk=1000 State=UNKNOWN"
      ];
      partitionName = [
        "batch Nodes=c0-[1-8],yoneda Default=YES MaxTime=INFINITE State=UP"
      ];
      # storagePass  = "olj2jememd";
    };
  };

  services.dnsmasq.enable = true;
  services.dnsmasq.extraConfig = ''
      address=/.cluster.local/10.101.0.1
    '';

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKiAS30ZO+wgfAqDE9Y7VhRunn2QszPHA5voUwo+fGOf jonas-3"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDULdlLC8ZLu9qBZUYsjhpr6kv5RH4yPkekXQdD7prkqapyoptUkO1nOTDwy7ZsKDxmp9Zc6OtdhgoJbowhGW3VIZPmooWO8twcaYDpkxEBLUehY/n8SlAwBtiHJ4mTLLcynJMVrjmTQLF3FeWVof0Aqy6UtZceFpLp1eNkiHTCM3anwtb9+gfr91dX1YsAOqxqv7ooRDu5rCRUvOi4OvRowepyuBcCjeWpTkJHkC9WGxuESvDV3CySWkGC2fF2LHkAu6SFsFE39UA5ZHo0b1TK+AFqRFiBAb7ULmtuno1yxhpBxbozf8+Yyc7yLfMNCyBpL1ci7WnjKkghQv7yM1xN2XMJLpF56v0slSKMoAs7ThoIlmkRm/6o3NCChgu0pkpNg/YP6A3HfYiEDgChvA6rAHX6+to50L9xF3ajqk4BUzWd/sCk7Q5Op2lzj31L53Ryg8vMP8hjDjYcgEcCCsGOcjUVgcsmfC9LupwRIEz3aF14AWg66+3zAxVho8ozjes= jonas.juselius@juselius.io"
  ];
}

