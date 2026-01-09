{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.features.desktop;

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

  x11 = {
    services.xserver = {
      enable = true;
      enableCtrlAltBackspace = true;
      desktopManager.xterm.enable = true;
      displayManager.gdm.enable = !(cfg.wayland.enable);
      wacom.enable = false;
    };
  };

  wayland = {
    # services.xserver.desktopManager.xterm.enable = true;
    services.displayManager.gdm.enable = true;
    services.displayManager.gdm.wayland = true;
    programs.regreet = {
      enable = false;
      cageArgs = [
        "-s"
        "-m"
        "last"
      ];
      settings = {
        background = {
          path = "${pkgs.nixos-artwork.wallpapers.mosaic-blue}/share/backgrounds/nixos/nix-wallpaper-mosaic-blue.png";
          fit = "Fill"; # Contain, Cover
        };
        GTK = {
          application_prefer_dark_theme = false;
        };
        appearance = {
          greeting_msg = "May the foo be with you.";
        };
      };
    };
    programs.sway.enable = true;
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

    environment.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

  hyprland = {
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    programs = {
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
    x11.enable = mkEnableOption "Enable X11";
    wayland.enable = mkEnableOption "Enable Wayland";
    hyprland.enable = mkEnableOption "Enable Hyprland";
    keybase.enable = mkEnableOption "Enable Keybase";
    plasma.enable = mkEnableOption "Enable KDE Plasma 6";
  };

  config = mkMerge [
    (mkIf cfg.enable configuration)
    (mkIf (cfg.enable && cfg.x11.enable) x11)
    (mkIf (cfg.enable && cfg.wayland.enable) wayland)
    (mkIf (cfg.enable && cfg.hyprland.enable) hyprland)
    (mkIf (cfg.enable && cfg.keybase.enable) keybase)
    (mkIf (cfg.enable && cfg.plasma.enable) plasma)
  ];
}
