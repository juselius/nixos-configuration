{ pkgs, config, ...}:
let
    yubikey = {
      slot = 2;
      twoFactor = false;
      storage = {
        device = "/dev/nvme0n1p2";
      };
    };
in
{
  networking = {
    hostName = "foldr";
    domain = "";
    search = [ ];
    firewall.allowedTCPPorts = [];
    firewall.extraCommands = '' '';
  };

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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKiAS30ZO+wgfAqDE9Y7VhRunn2QszPHA5voUwo+fGOf jonas-3"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDULdlLC8ZLu9qBZUYsjhpr6kv5RH4yPkekXQdD7prkqapyoptUkO1nOTDwy7ZsKDxmp9Zc6OtdhgoJbowhGW3VIZPmooWO8twcaYDpkxEBLUehY/n8SlAwBtiHJ4mTLLcynJMVrjmTQLF3FeWVof0Aqy6UtZceFpLp1eNkiHTCM3anwtb9+gfr91dX1YsAOqxqv7ooRDu5rCRUvOi4OvRowepyuBcCjeWpTkJHkC9WGxuESvDV3CySWkGC2fF2LHkAu6SFsFE39UA5ZHo0b1TK+AFqRFiBAb7ULmtuno1yxhpBxbozf8+Yyc7yLfMNCyBpL1ci7WnjKkghQv7yM1xN2XMJLpF56v0slSKMoAs7ThoIlmkRm/6o3NCChgu0pkpNg/YP6A3HfYiEDgChvA6rAHX6+to50L9xF3ajqk4BUzWd/sCk7Q5Op2lzj31L53Ryg8vMP8hjDjYcgEcCCsGOcjUVgcsmfC9LupwRIEz3aF14AWg66+3zAxVho8ozjes= jonas.juselius@juselius.io"
      ];
    };

    lan = {
      enable = true;

      krb5 = {
        enable = false;
        default_realm = "ACME";

        domain_realm = {
          "acme.com" = "ACME";
        };

        realms = {
          "ACME" = {
            admin_server = "dc.acme.com";
            kdc = "dc.acme.com";
          };
        };
      };
    };
  };

  boot = {
    # initrd.luks.yubikeySupport = true;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.luks.devices = {
      luksroot = {
        device = "/dev/disk/by-uuid/";
        preLVM = true;
        allowDiscards = true;
        # inherit yubikey;
      };
      luks-data = {
        device = "/dev/disk/by-uuid/";
        preLVM = true;
        allowDiscards = true;
        # inherit yubikey;
      };
    };
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

  services.dnsmasq.enable = false;
  services.dnsmasq.settings = {
      address = [ "/.local/127.0.0.1" ];
      # addn-hosts = "/etc/hosts.adhoc";
  };

  programs.singularity.enable = true;

  hardware.bluetooth.settings = {
    General = {
      AutoConnct = true;
      MultiProfile = "multiple";
    };
  };

  services.pcscd.enable = true; # For Yubikey ykman

  security.pam.yubico = {
    enable = true;
    mode = "client"; # "challenge-response";
    id = "12345";
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

