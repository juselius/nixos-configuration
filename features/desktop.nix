{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.features.desktop;

  configuration = {
    hardware.bluetooth.enable = true;
    hardware.pulseaudio = {
      enable = true;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      extraConfig = ''
        load-module module-bluetooth-policy
        load-module module-bluetooth-discover
      '';
    };

    powerManagement = {
      enable = false;
      cpuFreqGovernor = "ondemand";
    };

    programs.dconf.enable = true;

    services.dbus.enable = true;
    services.printing.enable = true;
    services.printing.drivers = [ pkgs.hplip ];

    services.xserver.enable = true;
    services.xserver.enableCtrlAltBackspace = true;
    services.xserver.layout = "us";
    services.xserver.xkbVariant = "altgr-intl";
    services.xserver.xkbOptions = "eurosign:e";

    services.xserver.displayManager.gdm.enable = true;
    services.xserver.displayManager.job.logToFile = true;
    services.xserver.desktopManager.xterm.enable = true;
    services.xserver.wacom.enable = true;

    services.upower.enable = true;

    fonts.fonts = with pkgs; [
      font-awesome
      caladea
      carlito
      cantarell-fonts
      comic-relief
      liberation_ttf
      fira
      fira-mono
      fira-code
      fira-code-symbols
      dejavu_fonts
      powerline-fonts
      unifont
      siji
      tamsyn
      noto-fonts
      noto-fonts-emoji
      material-icons
    ];
  };

  keybase = {
    services.keybase.enable = true;
    services.kbfs = {
      enable = true;
      extraFlags = [ "-label kbfs" ];
      mountPoint = "%h/keybase";
    };
  };

in
{
  options.features.desktop = {
    enable = mkEnableOption "Enable desktop configs";
    keybase.enable = mkEnableOption "Enable Keybase";
  };

  config = mkMerge [
    (mkIf cfg.enable configuration)
    (mkIf cfg.keybase.enable keybase)
  ];
}
