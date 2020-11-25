{ pkgs, ... }:
with pkgs;
{
  programs.singularity.enable = true;

  services.munge.enable = true;

  services.mysql = {
    enable = true;
    package = mysql;
    ensureUsers = [
      {
        name = "slurm";
        ensurePermissions = {
          "slurm_acct_db.*" = "ALL PRIVILEGES";
        };
      }
    ];
    initialDatabases = [
      { name = "slurm_acct_db"; }
    ];
  };

  services.slurm = {
    server.enable = true;
    controlMachine = "regnekraft";
    nodeName = [
      "DEFAULT CPUs=1 RealMemory=196000 TmpDisk=250000 State=UNKNOWN"
      "c0-[1-8] NodeAddr=c0-[1-8]"
    ];
    partitionName = [
      "run Nodes=c0-[1-8] Default=YES MaxTime=INFINITE State=UP"
    ];
    dbdserver = {
      enable = true;
      dbdHost = "regnekraft";
      storagePass  = "olj2jememd";
    };
  };
}
