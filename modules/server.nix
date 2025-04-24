{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.features.server;

  configuration = {
    environment.systemPackages = with pkgs; [
      nmap
    ];

    powerManagement = {
      enable = false;
      cpuFreqGovernor = "ondemand";
    };

    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };
in
{
  options.features.server = {
    enable = mkEnableOption "Enable server configs";
  };

  config = mkMerge [
    (mkIf cfg.enable configuration)
  ];
}
