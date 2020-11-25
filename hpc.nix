{ pkgs, config, ... }:
with pkgs;
let
  cfg = config.customize.hpc;

  common = {
    programs.singularity.enable = true;
  };

  slurmServer = {
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
      server.enable = cfg.slurm.enable;
      controlMachine = cfg.slurm.controlMachine;
      nodeName = cfg.slurm.nodeName;

      partitionName = cfg.slurm.partitionName;
        dbdserver = {
        enable = true;
        dbdHost = cfg.slurm.controlMachine;
        storagePass  = cfg.slurm.storagePass;
      };
    };
  };

  slurmClient = {
    services.munge.enable = true;

    services.slurm = {
      client.enable = true;
      controlMachine = cfg.slurm.controlMachine;
    };
  };
in
{
  options.customize.hpc = {
    slurm = {
      controlMachine = mkOption {
        type = types.str;
        default = null;
      };

      server = mkOption {
        type = types.bool;
        default = false;
      };

      client = mkOption {
        type = types.bool;
        default = false;
      };

      nodeName = mkOption {
        type = types.listOf types.str;
        default = [];
      };

      partitionName = mkOption {
        type = types.listOf types.str;
        default = [];
      };

      storagePass = mkOption {
        type = types.str;
        default = null;
      };
    };
  };

  config = mkMerge [
    common

    (mkIf cfg.slurm.server slurmServer)

    (mkIf cfg.slurm.client slurmClient)
  ];
}
