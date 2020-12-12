{ pkgs, config, ...}:
{
  imports = [
    ./features
    ./users.nix
    ./hosts.nix
    ./kernel.nix
    ./certificates.nix
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "nixos";
    domain = "local";
    search = [ "local" ];
  };

  security.pam.services.sshd.googleAuthenticator.enable = true;

  features = {
    desktop.enable = false;
    desktop.keybase.enable = false;
    cachix.enable = true;
    nodeExporter.enable = false;

    os = {
      boot = {
        uefi = true;
        device = "/dev/sda";
      };

      networkmanager.enable = true;
      externalInterface = "eno2";

      docker.enable = false;

      adminAuthorizedKeys = [
      ];
    };

    lan.enable = false;
  };
}

