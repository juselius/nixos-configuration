{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.features.packages;

  configuration = {
    environment.systemPackages = with pkgs; [
      stdenv
      findutils
      coreutils
      psmisc
      iputils
      nettools
      netcat
      inetutils
      rsync
      iotop
      wget
      neovim-unwrapped
      helix
      unzip
      zip
      bind
      file
      bc
      sshuttle
      lsof
      patchelf
      binutils
      git
      gcc
      nmap
      gnupg
      nixos-container
      nix-prefetch-git
      cachix
      attic-client
      cifs-utils
      keyutils
      fuse
      home-manager
      google-authenticator
    ];
  };
in {
  options.features.packages = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable default system packages";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable configuration)
  ];
}
