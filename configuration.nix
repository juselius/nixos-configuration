# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  host = "";
  desktop = false;
  thinkcentre = false;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./users.nix
      ./hosts.nix
      ./certificates.nix
    ];

  require = [
    (if thinkcentre then
    let
      e1000e = pkgs.linuxPackages.callPackage ./e1000e.nix {};
    in
    {
      nixpkgs.overlays = [
        (self: super: {
          linuxPackages = super.linuxPackages // { inherit e1000e; };
        })
      ];

      boot = {
        extraModulePackages = [ pkgs.linuxPackages.e1000e ];
        #kernelPackages = pkgs.linuxPackages_5_2;
      };
    } else {})
    (if desktop then import ./desktop.nix { inherit pkgs host;} else {})
  ];

  environment.systemPackages = import ./packages.nix {inherit pkgs;};

  boot =
  {
    loader.systemd-boot.enable = true;
    cleanTmpDir = true;
    initrd.checkJournalingFS = false;
  };

  # virtualisation.vmware.guest.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;
  virtualisation.docker.extraOptions = "--insecure-registry 10.0.0.0/8";

  networking = {
    networkmanager = {
       enable = true;
       unmanaged = [ "interface-name:veth*" "interface-name:docker*" ];
    };
    firewall.trustedInterfaces = [ "docker0" "cbr0" "veth+" ];

    # Networking for containers
    nat.enable = true;
    nat.internalInterfaces = ["veth+"];
    nat.externalInterface = "eno2";
  };

  # Select internationalisation properties.
  console = {
     font = "Lat2-Terminus16";
     keyMap = "us";
  };
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Oslo";

  programs.vim.defaultEditor = true;
  programs.fish.enable = true;
  programs.tmux.enable = true;

  services.openssh.enable = true;
  services.gvfs.enable = true;

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKiAS30ZO+wgfAqDE9Y7VhRunn2QszPHA5voUwo+fGOf jonas"
  ];

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
  system.stateVersion = "19.03";
  # system.autoUpgrade.enable = true;
  nixpkgs.config.allowUnfree = true;

}
// (if host != "" then { networking.hostName = host; } else {})

