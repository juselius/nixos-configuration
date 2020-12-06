{ pkgs, config, ... }:
with pkgs;
let
  cfg = config.facility.packages;

  configuration = {
    system.environment.systemPackages = [
      stdenv
      findutils
      coreutils
      psmisc
      iputils
      nettools
      netcat
      rsync
      iotop
      wget
      neovim-unwrapped
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
      cifs-utils
      keyutils
      fuse
      home-manager
      ssmtp
    ];
  };
in {
  options.facility.packages = {
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
