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
      device = "/dev/sda1";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_CTYPE="en_DK.UTF-8";
      LC_TIME="en_DK.UTF-8";
      LC_PAPER="en_DK.UTF-8";
      LC_NAME="en_DK.UTF-8";
      LC_ADDRESS="en_DK.UTF-8";
      LC_TELEPHONE="en_DK.UTF-8";
      LC_MEASUREMENT="en_DK.UTF-8";
      LC_IDENTIFICATION="en_DK.UTF-8";
    };
  };

  time.timeZone = "Europe/Oslo";

  # services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
  # services.xserver.displayManager.sessionCommands = ''
  #   # ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
  # '';

  features = {
    desktop.enable = false;
    laptop.enable = false;
    desktop.wayland.enable = false;
    desktop.keybase.enable = false;
    cachix.enable = false;

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
  services.dnsmasq.settings = {
      address = [ "/.local/127.0.0.1" ];
      # addn-hosts = "/etc/hosts.adhoc";
  };

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

