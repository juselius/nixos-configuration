{ pkgs, lib, config, ...}:
with lib;
let
  cfg = config.local;

  hostName = config.networking.hostName;

  kernelExtras =
    with pkgs;
    let kernel = config.system.build.kernel; in
    import ./kernel.nix { inherit pkgs stdenv fetchurl kernel; };

  desktop = import ./desktop.nix { inherit pkgs cfg; };

  lan = import ./lan.nix { inherit pkgs config; };

  docker = {
    virtualisation.docker.enable = true;
    virtualisation.docker.autoPrune.enable = true;
    virtualisation.docker.extraOptions = "--insecure-registry 10.0.0.0/8";
    networking = {
      nat.enable = true;
      nat.internalInterfaces = ["veth+"];
      nat.externalInterface = cfg.externalInterface;
    };
  };

  vmwareGuest = { virtualisation.vmware.guest.enable = true; };

  hypervGuest = { virtualisation.hypervGuest.enable = true; };

  libvirt = { virtualisation.libvirtd.enable = true; };

  boot = {
    boot = {
      loader.systemd-boot.enable = ! cfg.boot.bios;
      loader.grub = {
        enable = cfg.boot.bios;
        version = 2;
        device = cfg.boot.device;
      };
      cleanTmpDir = true;
      initrd.checkJournalingFS = false;
    };
  };
in
{
  options.local = {
    desktop.enable = mkEnableOption "Enable desktop configs";

    lan = {
      enable = mkEnableOption "Enable LAN configs";

      domain = mkOption {
        type = types.str;
        default = "";
      };

      domainSearch = mkOption {
        type = types.listOf types.str;
        default = [ cfg.lan.domain ];
      };

      samba.extraConfig = mkOption {
        type = types.str;
        default = "";
      };

      dnsmasq.extraConfig = mkOption {
        type = types.str;
        default = "";
      };

      krb5 = {
        default_realm = mkOption {
          type = types.str;
          default = "";
        };

        domain_realm = mkOption {
          type = types.set;
          default = {};
        };

        realms = mkOption {
          type = types.set;
          default = {};
        };
      };
    };

    boot.bios = mkEnableOption "Enable BIOS boot";
    boot.device = mkOption {
      type = types.str;
      default = "/dev/sda";
    };

    externalInterface = mkOption {
      type = types.str;
      default = "eth0";
      description = "External interface (for Docker primarily)";
    };

    virtualisation = {
      guest.vmware = mkEnableOption "Enable vmware guest";
      guest.hyperv = mkEnableOption "Enable hyperv guest";
      libvirt = mkEnableOption "Enable libvirt";
      docker = mkEnableOption "Enable docker";
    };

    kernelExtras = mkEnableOption "Include kernel configs in ./kernel.nix";
  };

  config = mkMerge [
    boot

    (mkIf cfg.desktop.enable desktop)

    (mkIf cfg.lan.enable lan)

    (mkIf cfg.kernelExtras kernelExtras)

    (mkIf cfg.virtualisation.docker docker)

    (mkIf cfg.virtualisation.libvirt libvirt)

    (mkIf cfg.virtualisation.guest.vmware vmwareGuest)

    (mkIf cfg.virtualisation.guest.hyperv hypervGuest)

  ];
}
