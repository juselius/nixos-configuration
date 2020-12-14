{ pkgs, config, ...}:
{
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

  imports = [
    ./.
    ./kernel.nix
    ./hardware-configuration.nix
  ];

}

