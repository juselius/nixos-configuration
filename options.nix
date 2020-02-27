{ pkgs, config }:
{
  hostName = "";
  desktop = true;
  lan = false;
  uefi = true;
  bootdisk = "/dev/sda";
  eth="eno2";
  virtualization = "libvirt";
  kernelExtras = true;
}
