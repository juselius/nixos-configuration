{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.features.cachix;

  folder = ../cachix;

  toImport = name: value: folder + ("/" + name);

  filterCaches = key: value: value == "regular" && hasSuffix ".nix" key;

  imports = mapAttrsToList toImport (
    filterAttrs filterCaches (builtins.readDir folder)
  );

  configuration = {
    nix.settings.substituters = ["https://cache.nixos.org/"];
  };
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
