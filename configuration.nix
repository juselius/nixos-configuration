{ pkgs, config, ...}:
{
  networking = {
    hostName = "nixos";
    domain = "local";
    search = [ "local" ];
    firewall.allowedTCPPorts = [];
    firewall.extraCommands = '' '';
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    # initrd.luks.devices = {
    #   luksroot = {
    #     device = "/dev/sda1";
    #     preLVM = true;
    #     allowDiscards = true;
    #   };
    # };
    loader.grub = {
      enable = false;
      version = 2;
      device = "/dev/sda1";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  i18n = {
    defaultLocale = "en_DK.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "en_DK.UTF-8";
    };
  };

  time.timeZone = "Europe/Oslo";

  # services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
  # services.xserver.displayManager.sessionCommands = ''
  #   # ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
  # '';

  features = {
    desktop.enable = true;
    laptop.enable = true;
    desktop.wayland.enable = false;
    desktop.keybase.enable = true;
    cachix.enable = true;

    pki = {
      enable = false;
      certmgr.enable = true;
      certs = {
        foo = { hosts = [ "localhost" ]; };
      };
    };

    os = {
      networkmanager.enable = true;
      externalInterface = "eno2";

      docker.enable = true;

      adminAuthorizedKeys = [
      ];
    };
  };

  services.dnsmasq.enable = false;
  services.dnsmasq.extraConfig = ''
    address=/.cluster.local/10.101.0.1
  '';

  programs.singularity.enable = false;

  hardware.bluetooth.settings = {
    General = {
      AutoConnct = true;
      MultiProfile = "multiple";
    };
  };

  services.pcscd.enable = false; # For Yubikey ykman

  security.pam.yubico = {
    enable = false;
    mode = "client"; # "challenge-response";
    id = "";
    control = "sufficient";
  };

  # nix = {
  #    package = pkgs.nixFlakes;
  #    extraOptions = pkgs.lib.optionalString (config.nix.package == pkgs.nixFlakes)
  #      "experimental-features = nix-command flakes";
  # };

  imports = [
    ./.
    ./kernel.nix
    #"${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/lenovo/thinkpad/x1/7th-gen"
    ./hardware-configuration.nix
  ];

}

