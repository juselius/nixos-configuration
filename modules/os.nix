{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.features.os;

  configuration = {
    networking = {
      networkmanager = {
        enable = cfg.networkmanager.enable;
        unmanaged = [ "interface-name:veth*" "interface-name:docker*" ];
      };
      firewall.trustedInterfaces = [ "docker0" "cbr0" "veth+" ];
    };

    users.extraUsers.admin.openssh.authorizedKeys.keys =
      cfg.adminAuthorizedKeys;

    users.extraUsers.root.openssh.authorizedKeys.keys =
      cfg.adminAuthorizedKeys;

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

    programs.vim.defaultEditor = true;
    programs.fish.enable = true;
    programs.tmux.enable = true;

    services.openssh.enable = true;
    services.gvfs.enable = true;
    services.fwupd.enable = true;

    security.sudo.extraConfig = ''
      Defaults env_keep+=SSH_AUTH_SOCK
      Defaults lecture=never
      Defaults shell_noargs
      root   ALL=(ALL) SETENV: ALL
      %wheel ALL=(ALL) NOPASSWD: ALL, SETENV: ALL
    '';

    security.rtkit.enable = true;
    security.pam.services.sshd.googleAuthenticator.enable = true;

    # $ ecryptfs-migrate-home -u <username>
    # security.pam.enableEcryptfs = true;

    # The NixOS release to be compatible with for stateful data such as databases.
    system.stateVersion = "20.09";
    system.autoUpgrade.enable = true;
    nixpkgs.config.allowUnfree = true;

    boot = {
      loader.systemd-boot.enable = cfg.boot.uefi;
      loader.grub = {
        enable = ! cfg.boot.uefi;
        version = 2;
        device = cfg.boot.device;
      };
      cleanTmpDir = true;
      initrd.checkJournalingFS = false;
    };
  };

  docker = {
    virtualisation.docker.enable = cfg.docker.enable;
    virtualisation.docker.autoPrune.enable = true;
    virtualisation.docker.extraOptions = "--insecure-registry 10.0.0.0/8";
    networking = {
      nat.enable = true;
      nat.internalInterfaces = ["veth+"];
      nat.externalInterface =
        if cfg.externalInterface == null then []
        else cfg.externalInterface;
    };
  };

  mailRelay = {
    services.ssmtp = {
      enable = true;
      useTLS = true;
      root = cfg.mailRelay.adminEmail;
      domain = cfg.mailRelay.mailDomain;
      hostName = cfg.mailRelay.mailGateway;
      authUser = cfg.mailRelay.mailAuthUser;
      authPassFile = "/run/keys/ssmtp-authpass";
    };
  };

  nfs = {
    networking = {
      firewall.allowedTCPPorts = [ 111 2049 ];
      firewall.allowedUDPPorts = [ 111 2049 24007 24008 ];
    };

    environment.systemPackages = with pkgs; [ nfs-utils ];

    services.nfs.server = {
      enable = true;
      exports = cfg.nfs.exports;
    };
  };

in
{
  options.features.os = {
    networkmanager.enable = mkEnableOption "Enable NetworkManager";

    docker.enable = mkEnableOption "Enable Docker";

    boot.uefi = mkOption {
      type = types.bool;
      default = true;
      description = "Enable systemd UEFI boot";
    };

    boot.device = mkOption {
      type = types.str;
      default = "/dev/sda";
      description = "Boot disk (e.g. /dev/sda) for GRUB2";
    };

    externalInterface = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "External interface (i.e. for Docker nat)";
    };

    adminAuthorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    mailRelay = {
      enable = mkEnableOption "Enable mail realy using ssmtp";

      adminEmail = mkOption {
        type = types.str;
        default = "root";
      };

      mailDomain = mkOption {
        type = types.str;
        default = "local";
      };

      mailGateway = mkOption {
        type = types.str;
        default = "";
      };

      mailAuthUser = mkOption {
        type = types.str;
        default = "";
      };
    };

    nfs = {
      enable = mkEnableOption "Enable nfs fileserver";

      exports = mkOption {
        type = types.str;
        default = "";
      };
    };
  };

  config = mkMerge [
    configuration

    (mkIf cfg.docker.enable docker)

    (mkIf cfg.mailRelay.enable mailRelay)

    (mkIf cfg.nfs.enable nfs)
  ];
}
