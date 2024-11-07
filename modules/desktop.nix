{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.features.desktop;

  configuration = {
    hardware.bluetooth.enable = true;
    hardware.pulseaudio = {
      enable = false;
      extraModules = [];
      extraConfig = ''
        load-module module-bluetooth-policy
        load-module module-bluetooth-discover
      '';
    };
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      wireplumber = {
        enable = true;
        # Need to generate lua config for bluetooth codecs
        configPackages = [
          (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
            bluez_monitor.properties = {
              ["bluez5.enable-sbc-xq"] = true,
              ["bluez5.enable-msbc"] = true,
              ["bluez5.enable-hw-volume"] = true,
              ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
            }
          '')
        ];
      };
      # TODO: Is this needed?
      jack.enable = true;
    };

  environment.systemPackages = with pkgs; [
    pamixer # pulseaudio sound mixer
    pavucontrol # pulseaudio volume control
  ];

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
    services.xserver.displayManager.gdm.enable = ! cfg.wayland.enable;
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
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

    security.pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
  };

  wayland = {
    # services.xserver.displayManager.gdm.wayland = true;
    programs.regreet.enable = true;
    programs.sway.enable = true;
    programs.hyprland.enable = true;
    programs.river.enable = true;
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
    (mkIf cfg.wayland.enable wayland)
    (mkIf cfg.keybase.enable keybase)
  ];
}
