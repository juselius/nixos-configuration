{ pkgs, config, lib, ... }:
with lib;
let
  folder = ../cachix;

  toImport = name: value: folder + ("/" + name);

  filterCaches = key: value: value == "regular" && hasSuffix ".nix" key;

  imports = mapAttrsToList toImport (
    filterAttrs filterCaches (builtins.readDir folder)
  );

  configuration = {
    nix.binaryCaches = ["https://cache.nixos.org/"];
  };

  cfg = config.features.cachix;
in {
  options.features.cachix = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable cachix";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable configuration)
  ];

  inherit imports;
}
