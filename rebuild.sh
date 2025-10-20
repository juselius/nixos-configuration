#!/usr/bin/env bash

cd $(dirname $0)

# Assume that if there are no args, you want to switch to the configuration
cmd=${1:-switch}
shift

nixpkgs_pin=$(nix eval --raw -f npins/default.nix nixpkgs)
nix_path="nixpkgs=${nixpkgs_pin}"
nix_config="nixos-config=${PWD}/configuration.nix"

# Without --no-reexec, nixos-rebuild will compile nix and use the compiled nix to
# evaluate the config, wasting several seconds
sudo env NIX_PATH="${nix_path}" nixos-rebuild "$cmd" --no-reexec "$@" -I "${nix_config}" --log-format internal-json -v |& nom --json
