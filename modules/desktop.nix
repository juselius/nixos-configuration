{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.features.desktop;

  configuration = {
    hardware.bluetooth.enable = true;
    hardware.pulseaudio = {
      enable = true;
      extraModules = [];
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

    security.pam.services.login.enableGnomeKeyring = true;

    services.dbus.enable = true;
    services.dbus.packages = [ pkgs.gnome3.gnome-keyring pkgs.gcr ];

    services.blueman.enable = true;

    services.printing.enable = true;
    services.printing.drivers = [ pkgs.hplip ];

    services.upower.enable = true;

    services.xserver.enable = true;
    services.xserver.enableCtrlAltBackspace = true;
    services.xserver.xkb = {
      layout = "us";
      variant = "altgr-intl";
      options = "eurosign:e";
    };

    services.displayManager.logToFile = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.wacom.enable = true;
    services.xserver.desktopManager.xterm.enable = true;

    fonts.packages = with pkgs; [
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

    security.pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
  };

  sway = {
    services.xserver.displayManager.gdm.wayland = true;
    programs.sway.enable = true;
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
    wayland.enable = mkEnableOption "Enable Wayland";
  };

  config = mkMerge [
    (mkIf cfg.enable configuration)
    (mkIf cfg.wayland.enable sway)
    (mkIf cfg.keybase.enable keybase)
  ];
}
