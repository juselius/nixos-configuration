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

    programs.vim.defaultEditor = true;
    programs.vim.enable = true;
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
    system.stateVersion = "21.05";
    nixpkgs.config.allowUnfree = true;

    boot = {
      tmp.cleanOnBoot = true;
      initrd.checkJournalingFS = false;
    };

    nix = {
        #package = pkgs.nixVersions.stable;
        # package = pkgs.nixVersions.nix_2_23;
        extraOptions = ''
          experimental-features = nix-command flakes impure-derivations
          connect-timeout = 5
          log-lines = 25
          warn-dirty = false
          fallback = true
        '';
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

  nfs = {
    networking =
      if cfg.nfs.openFirewall then
        {
          firewall.allowedTCPPorts = [ 111 2049 ];
          firewall.allowedUDPPorts = [ 111 2049 24007 24008 ];
        }
      else {};

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

    externalInterface = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "External interface (i.e. for Docker nat)";
    };

    adminAuthorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    nfs = {
      enable = mkEnableOption "Enable nfs fileserver";

      exports = mkOption {
        type = types.str;
        default = "";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to open the required ports in the firewall.
        '';
      };

    };
  };

  config = mkMerge [
    configuration

    (mkIf cfg.docker.enable docker)

    (mkIf cfg.nfs.enable nfs)
  ];
}
