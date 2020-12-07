{pkgs, stdenv, fetchurl, config, kernel ? null, ...}:
let
  kernel = if kernel == null then config.system.build.kernel else kernel;
in
  {
    nixpkgs.overlays = [];

    boot = {
      extraModulePackages = [];
      kernelPackages = kernel;
    };
  }
