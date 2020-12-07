{ pkgs, config, ... }:
with pkgs;
let
  cfg = config.feature.nodeExporter;

  configuration = {
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
  options.feature.nodeExporter = {
    enable = mkenableOption "Enable Prometheus node exporter";
  };

  config = mkMerge [
    (mkIf cfg.enable configuration)
  ];
}
