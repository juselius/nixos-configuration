{ pkgs, lib, config, ...}:
with lib;
let
  cfg = config.customize;

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
      nat.externalInterface =
        if cfg.externalInterface == null then []
        else cfg.externalInterface;
    };
  };

  vmwareGuest = { virtualisation.vmware.guest.enable = true; };

  hypervGuest = { virtualisation.hypervGuest.enable = true; };

  libvirt = { virtualisation.libvirtd.enable = true; };

  boot = {
    boot = {
      loader.systemd-boot.enable = cfg.boot.uefi;
      loader.grub = {
        enable = ! cfg.boot.uefi;
        version = 2;
        device = cfg.boot.device;
      };
      cleanTmpDir = true;
      initrd.checkJournalingFS = false;
    };
  };
in
{
  options.customize = {
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

      krb5 = {
        enable = mkEnableOption "Enable Kerberos";

        default_realm = mkOption {
          type = types.str;
          default = "";
        };

        domain_realm = mkOption {
          type = types.attrs;
          default = {};
        };

        realms = mkOption {
          type = types.attrs;
          default = {};
        };
      };
    };

    boot.uefi = mkOption {
      type = types.bool;
      default = true;
      description = "Enable UEFI boot";
    };

    boot.device = mkOption {
      type = types.str;
      default = "/dev/sda";
    };

    externalInterface = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "External interface (for Docker nat)";
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
