{ host, pkgs, ... }:
let
  e1000e = pkgs.linuxPackages.callPackage ./e1000e.nix {};
  curry = if host == "curry" then
    {
      nixpkgs.overlays = [
        (self: super: {
          linuxPackages = super.linuxPackages // { inherit e1000e; };
        })
      ];

      boot = {
        extraModulePackages = [ pkgs.linuxPackages.e1000e ];
        #kernelPackages = pkgs.linuxPackages_5_2;
      };

      powerManagement = {
        enable = false;
        cpuFreqGovernor = "ondemand";
      };
      virtualisation.libvirtd.enable = true;
    }
    else {};
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

  programs.dconf.enable = true;

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
