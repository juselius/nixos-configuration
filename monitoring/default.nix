{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hpc.monitoring;

  mkScrapeConfigs = configs: flip mapAttrsToList configs (k: v:
    let
      static_configs = flip map v.hostNames (name: {
        targets = [ "${name}:${toString v.port}" ];
        labels.alias = name;
      });
    in
    (mkIf (static_configs != []) ({
      inherit static_configs;
      job_name = k;
      scrape_interval = "30s";
    } // (removeAttrs v [ "hostNames" "port" ]))));

  alertmanager = {
    systemd.services.alertmanager.serviceConfig.LimitNOFILE = 1024000;
    services.prometheus.alertmanager = {
      enable = true;
      configuration = {
        route = {
          receiver = "default";
          routes = [
            {
              group_by = [ "alertname" "alias" ];
              group_wait = "5s";
              group_interval = "2m";
              repeat_interval = "2h";
              match = { severity = "page"; };
              receiver = "page";
            }
            {
              group_by = [ "alertname" ];
              group_wait = "5s";
              group_interval = "2m";
              repeat_interval = "2h";
              match_re = { metric = ".+"; };
              receiver = "page";
            }
            {
              group_by = [ "alertname" "alias" ];
              group_wait = "30s";
              group_interval = "2m";
              repeat_interval = "6h";
              receiver = "all";
            }
          ];
        };
        receivers = [
          ({ name = "all"; } // cfg.server.alertReceiver)
          { name = "page"; }
          { name = "default"; }
        ];
      };
    };
  };

  prometheus = {
    systemd.services.prometheus.serviceConfig.LimitNOFILE = 1024000;
    services.prometheus = {
      enable = true;
      ruleFiles = singleton (pkgs.writeText "prometheus-rules.yml" (builtins.toJSON {
        groups = singleton {
          name = "alerting-rules";
          rules = import ./alert-rules.nix { inherit lib; };
        };
      }));
      scrapeConfigs = (mkScrapeConfigs ({
        node = {
          hostNames = cfg.server.scrapeHosts;
          port = 9100;
        };
      }));
    };
  };

  prometheusAlertmanagers = {
    services.prometheus = {
      alertmanagers = singleton {
        static_configs = singleton {
          targets = flip map cfg.server.scrapeHosts (n: "${n}:9093");
        };
      };
    };
  };

  nodeExporter = {
    services.prometheus.exporters = {
      node = {
        enable = true;
        openFirewall = true;
        extraFlags = [ "--collector.disable-defaults" ];
        enabledCollectors = [
          "netstat"
          "rapl"
          "stat"
          "systemd"
          "textfile"
          "textfile.directory /run/prometheus-node-exporter"
          "thermal_zone"
          "time"
          "udp_queues"
          "uname"
          "vmstat"
          "cpu"
          "cpufreq"
          "diskstats"
          "edac"
          "filesystem"
          "hwmon"
          "interrupts"
          "ksmd"
          "loadavg"
          "meminfo"
          "pressure"
          "timex"
          "nfsd"
          "nfs"
        ];
      };
    };
  };
in {
  options = {
    hpc.monitoring = {
      server = {
        enable = mkEnableOption "HPC cluster monitoring server with prometheus";

        scrapeHosts = mkOption {
          type = types.listOf types.str;
          default = [];
        };

        alertReceiver = mkOption {
          type = types.attrs;
          default = {};
        };
      };
    };
  };

  config = mkMerge [

    (mkIf cfg.server.enable (mkMerge [
      prometheus
      alertmanager
      prometheusAlertmanagers
    ]))

    nodeExporter
  ];
}
