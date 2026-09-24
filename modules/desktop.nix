{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.features.desktop;
  sources = import ../npins;

  configuration = {
    hardware.bluetooth.enable = true;
    services.pulseaudio = {
      enable = false;
      extraModules = [ ];
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
    services.dbus.packages = [
      pkgs.gnome-keyring
      pkgs.gcr
    ];

    services.blueman.enable = true;

    services.printing.enable = true;
    services.printing.drivers = [ pkgs.hplip ];

    services.upower.enable = lib.mkDefault true;

    services.displayManager = {
      enable = true;
      logToFile = true;
    };

    fonts.packages = with pkgs; [
      ubuntu-sans
      ubuntu-classic
      vollkorn
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
      powerline-symbols
      unifont
      siji
      tamsyn
      noto-fonts
      noto-fonts-color-emoji
      material-icons
      nerd-fonts.jetbrains-mono
      nerd-fonts._0xproto
      nerd-fonts.droid-sans-mono
    ];

    security.pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
    services.xserver.xkb = lib.mkDefault {
      layout = "us";
      variant = "altgr-intl";
      options = "eurosign:e";
    };

  };

  wayland = {
    services = {
      displayManager.gdm.enable = true;
      greetd.settings.default_session.user = "greeter";
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };

    # users.extraUsers.greeter = {
    #  extraGroups = [
    # "seat"
    # "video"
    # "render"
    #  ];
    # };

    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on screen
      # Without these bootlogs will spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };

    # programs.river.enable = true;
  };

  plasma = {
    services = {
      blueman.enable = lib.mkForce false;

      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };

      desktopManager.plasma6 = {
        enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      pinentry-qt
      wl-clipboard
    ];
  };

  tiling = {
    programs = {
      niri.enable = true;
      hyprland.enable = true;
      hyprlock.enable = true;
      waybar.enable = false;
    };

    security = {
      pam.services.hyprlock = {
        text = ''
          auth include login
        '';
      };
    };
  };

  gnome = {
    services = {
      blueman.enable = lib.mkForce false;
      desktopManager.gnome.enable = true;

      displayManager.gdm = {
        enable = lib.mkForce true;
        wayland = true;
      };
    };

    environment.systemPackages = with pkgs; [
      gnome-tweaks
      wl-clipboard
      pinentry-gnome3
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
    wayland.enable = mkEnableOption "Enable Wayland";
    tiling.enable = mkEnableOption "Enable tiling WM(s)";
    keybase.enable = mkEnableOption "Enable Keybase";
    plasma.enable = mkEnableOption "Enable KDE Plasma 6";
    gnome.enable = mkEnableOption "Enable GNOME";
  };

  config = mkMerge [
    (mkIf cfg.enable configuration)
    (mkIf (cfg.enable && cfg.wayland.enable) wayland)
    (mkIf (cfg.enable && cfg.tiling.enable) tiling)
    (mkIf (cfg.enable && cfg.keybase.enable) keybase)
    (mkIf (cfg.enable && cfg.plasma.enable) plasma)
    (mkIf (cfg.enable && cfg.gnome.enable) gnome)
  ];
}
