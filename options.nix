{ pkgs, config }:
{
  host = "coyoneda";
  desktop = true;
  uefi = true;
  bootdisk = "/dev/sda";
  thinkcentre =
    if true then
      with pkgs;
      let kernel = config.system.build.kernel; in
      import ./thinkcentre.nix { inherit pkgs stdenv fetchurl kernel; }
    else {};
}
