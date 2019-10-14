{ host, pkgs, ... }:
let
in
{
  hardware.bluetooth.enable = true;
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    extraConfig = "
      load-module module-bluetooth-policy
      load-module module-bluetooth-discover
    ";
  };

  powerManagement = {
    enable = false;
    cpuFreqGovernor = "ondemand";
  };

  virtualisation.libvirtd.enable = true;

  programs.dconf.enable = true;

  services.dbus.enable = true;
  services.dnsmasq.enable = true;
  services.dnsmasq.servers = [
    "/cluster.local/127.0.0.1#4053"
  ];
  services.keybase.enable = true;
  services.kbfs = {
    enable = true;
    extraFlags = [ "-label kbfs" ];
    mountPoint = "%h/keybase";
  };

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  services.xserver.enable = true;
  services.xserver.enableCtrlAltBackspace = true;
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "altgr-intl";
  services.xserver.xkbOptions = "eurosign:e";

  services.xserver.displayManager.slim.enable = true;
  services.xserver.displayManager.slim.defaultUser = "jonas";
  services.xserver.displayManager.job.logToFile = true;

  services.upower.enable = true;

  fonts.fonts = with pkgs; [
    caladea
    carlito
    cantarell-fonts
    comic-relief
    liberation_ttf
    fira
    fira-mono
    dejavu_fonts
    powerline-fonts
  ];
} // curry
