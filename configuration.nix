# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  cfg = config.local;
in
{
  imports =
    [
      ./options.nix
      ./local.nix
      ./cachix.nix
      ./users.nix
      ./hosts.nix
      ./certificates.nix
      ./hardware-configuration.nix
    ];

  environment.systemPackages = import ./packages.nix {inherit pkgs cfg;};

  nixpkgs.overlays = [];

  networking = {
    networkmanager = {
       enable = true;
       unmanaged = [ "interface-name:veth*" "interface-name:docker*" ];
    };
    firewall.trustedInterfaces = [ "docker0" "cbr0" "veth+" ];
  };

  # Select internationalisation properties.
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

  # Set your time zone.
  time.timeZone = "Europe/Oslo";

  programs.vim.defaultEditor = true;
  programs.fish.enable = true;
  programs.tmux.enable = true;

  services.openssh.enable = true;
  services.gvfs.enable = true;

  services.fwupd.enable = true;

  security.sudo.extraConfig =
    ''
      Defaults env_keep+=SSH_AUTH_SOCK
      Defaults lecture=never
      Defaults shell_noargs
      root   ALL=(ALL) SETENV: ALL
      %wheel ALL=(ALL) NOPASSWD: ALL, SETENV: ALL
     '';

  security.rtkit.enable = true;

  # $ ecryptfs-migrate-home -u <username>
  # security.pam.enableEcryptfs = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "20.09";
  # system.autoUpgrade.enable = true;
  nixpkgs.config.allowUnfree = true;
}
