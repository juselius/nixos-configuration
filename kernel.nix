{pkgs, stdenv, fetchurl, config, ...}:
let
  sources = import ./npins;
  system = builtins.currentSystem;
  overlay-unstable = arch: _final: _prev: {
    stable = import sources.nixpkgs { system = arch; };
    unstable = import sources.unstable { system = arch; };
  };
in
  {
    nixpkgs.overlays = [(overlay-unstable system)];

    boot = {
      extraModulePackages = [];
      # kernelPackages = pkgs.linuxPackages_5_9;
    };
  }
