{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.hpc;

  common = {
    services.beegfs7.enable = true;
    services.beegfs7.beegfs = {
      mds0-0 = {
        mgmtdHost = "mds0-0";
        connAuthFile = "";
        client = {
          enable = true;
          mountPoint = "/work";
        };
      };
    };

    programs.singularity.enable = true;

    services.munge.enable = true;
    environment.etc."munge/munge.key" = {
        source = cfg.mungeKey;
        mode = "0400";
        uid = 997;
        gid = 0;
    };

    services.slurm = {
      controlMachine = cfg.slurm.controlMachine;
      nodeName = cfg.slurm.nodeName;
      partitionName = cfg.slurm.partitionName;
      extraConfig = ''
        AccountingStorageType=accounting_storage/filetxt
        JobAcctGatherType=jobacct_gather/linux
      '';
    };

    environment.systemPackages = with pkgs; [
      ibutils
      git
      cmake
      nco
      neovim
      python3
      emacs
      gfortran
      openmpi
    ];
  };

  prometheusServer = {
    # services.prometheus ={
    #   enable = true;
    #   scrapeConfigs = [
    #     {
    #       job_name = "chrysalis";
    #       static_configs = [
    #         {
    #           targets = [
    #             "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
    #           ];
    #         }
    #       ];
    #     }
    #   ];
    # };

    # services.certmgr

    services.grafana = {
      enable = true;
      domain = "grafana.vortex.juselius.io";
      port = 2342;
      addr = "127.0.0.1";
    };

    # nginx reverse proxy
    security.acme.acceptTerms = true;
    security.acme.email = "innovasjon@itpartner.no";
    services.nginx = {
      enable = true;
      statusPage = true;
      virtualHosts = {
        "acmechallenge.juselius.io" = {
      # Catchall vhost, will redirect users to HTTPS for all vhosts
      serverAliases = [ "*.juselius.io" ];
      # /var/lib/acme/.challenges must be writable by the ACME user
      # and readable by the Nginx user.
      # By default, this is the case.
      locations."/.well-known/acme-challenge" = {
        root = "/var/lib/acme/.challenges";
      };
      locations."/" = {
        return = "301 https://$host$request_uri";
      };
    };
    ${config.services.grafana.domain} = {
      # forceSSL = true;
      # enableACME = true;
      serverAliases = [];
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
        proxyWebsockets = true;
      };
    };
    "prometheus.vortex.juselius.io" = {
    # forceSSL = true;
    # enableACME = true;
    serverAliases = [];
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";
      proxyWebsockets = true;
      };
      };
      "alertmanager.vortex.juselius.io" = {
      # forceSSL = true;
      # enableACME = true;
      serverAliases = [];
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.prometheus.alertmanager.port}";
        proxyWebsockets = true;
      };
    };
  };
};
  };

  # prometheusExporter = {
  #   services.prometheus.exporters = {
  #       node.enable = true;
  #       node.enabledCollectors = [ "systemd" ];
  #   };
  # };

  slurmServer = {
    # services.mysql = {
    #   enable = true;
    #   package = pkgs.mysql;
    #   ensureUsers = [
    #     {
    #       name = "slurm";
    #       ensurePermissions = {
    #         "slurm_acct_db.*" = "ALL PRIVILEGES";
    #       };
    #     }
    #   ];
    #   initialDatabases = [
    #     { name = "slurm_acct_db"; }
    #   ];
    # };

    services.slurm = {
      server.enable = cfg.slurm.server;
      extraConfig = ''
        MailDomain=itpartner.no
        MailProg=${pkgs.ssmtp}/bin/ssmtp
      '';
      # dbdserver = {
      #   enable = true;
      #   dbdHost = cfg.slurm.controlMachine;
      #   storagePass  = cfg.slurm.storagePass;
      # };
    };

    services.ssmtp = {
      enable = true;
      useTLS = true;
      hostName = "smtpgw.itpartner.no:465";
      root = "jonas.juselius@tromso.serit.no";
      domain = "itpartner.no";
      authUser = "innovasjon";
      authPassFile = "/run/keys/ssmtp-authpass";
    };
  };

  slurmClient = {
    services.slurm.client.enable = cfg.slurm.client;
  };

  ibutils = pkgs.callPackage ./ibutils.nix {};
in
{
  options.hpc = {
    mungeKey = mkOption {
      type = types.path;
      default = null;
    };

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

    prometheusServer = mkEnableOption "Enable Prometheus server";
    # prometheusExporter = mkEnableOption "Enable Prometheus node exporter";
  };

  config = mkMerge [
    common

    (mkIf cfg.slurm.server slurmServer)

    (mkIf cfg.slurm.client slurmClient)

    (mkIf cfg.prometheusServer prometheusServer)

    # (mkIf cfg.prometheusExporter prometheusExporter)
  ];

  imports = [
    ./beegfs
    ./monitoring
  ];
}
