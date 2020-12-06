{pkgs, stdenv, fetchurl, kernel ? config.system.build.kernel, ...}:
let
  e1000e =
    # assert stdenv.lib.versionOlder kernel.version "4.10";
    stdenv.mkDerivation rec {
      name = "e1000e-${version}-${kernel.version}";
      version = "3.6.0";

      src = fetchurl {
        url = "mirror://sourceforge/e1000/e1000e-${version}.tar.gz";
        sha256 = "0878j3rxlxckf71g3sv1rwf9077pq0almgp46q5vmyinsbb0zna1";
      };

      hardeningDisable = [ "pic" ];

      configurePhase = ''
        cd src
        kernel_version=${kernel.modDirVersion}
        sed -i -e 's|/lib/modules|${kernel.dev}/lib/modules|' Makefile
        sed -i -e 's|/lib/modules|${kernel.dev}/lib/modules|' common.mk
        export makeFlags="BUILD_KERNEL=$kernel_version"
      '';

      installPhase = ''
        install -v -D -m 644 e1000e.ko "$out/lib/modules/$kernel_version/kernel/drivers/net/e1000e/e1000e.ko"
      '';

      dontStrip = true;

      enableParallelBuilding = true;

      meta = {
        description = "Linux kernel drivers for Intel Ethernet adapters and LOMs (LAN On Motherboard)";
        homepage = http://e1000.sf.net/;
        license = stdenv.lib.licenses.gpl2;
      };
    };

  e1000Package = self: super: {
    linuxPackages = super.linuxPackages // { inherit e1000e; };
  };
in
  {
    # nixpkgs.overlays = [ e1000Package ];

    boot = {
      # extraModulePackages = [ pkgs.linuxPackages.e1000e ];
      # kernelPackages = pkgs.linuxPackages_5_2;
    };
  }
