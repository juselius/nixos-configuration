
# WARN: this file will get overwritten by $ cachix use <name>
{ pkgs, config, lib, ... }:
let
  folder = ../cachix;

  toImport = name: value: folder + ("/" + name);

  filterCaches = key: value: value == "regular" && lib.hasSuffix ".nix" key;

  imports = lib.mapAttrsToList toImport (
    lib.filterAttrs filterCaches (builtins.readDir folder)
  );

  configuration = {
    inherit imports;
    nix.binaryCaches = ["https://cache.nixos.org/"];
  };

  cfg = config.feature.cachix;
in {
  options.feature.cachix = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable cachix";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable configuration)
  ];
}
