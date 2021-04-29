{ pkgs, config, ...}:
{
  networking = {
    hostName = "nixos";
    domain = "local";
    search = [ "local" ];
    firewall.allowedTCPPorts = [];
    firewall.extraCommands = '' '';
  };

  # boot.initrd.luks.devices = {
  #   luksroot = {
  #     device = "/dev/sda1";
  #     preLVM = true;
  #     allowDiscards = true;
  #   };
  # };
  # boot.loader.efi.canTouchEfiVariables = true;

  features = {
    desktop.enable = false;
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
      boot = {
        uefi = true;
        device = "/dev/sda1";
      };

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

  hardware.bluetooth.config = {
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
    ./hardware-configuration.nix
  ];

}

