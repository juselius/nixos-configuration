let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  programms = with pkgs; [
    nix
    git
    npins
    openssh
    colmena
  ];
}
