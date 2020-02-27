{ pkgs, ... }:
with pkgs;
[
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
    glib
    home-manager
  ]

