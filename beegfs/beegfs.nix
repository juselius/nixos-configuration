{ pkgs, ...}:
with pkgs;
let
  version = "7.2";
in stdenvNoCC.mkDerivation {
  pname = "beegfs";
  inherit version;

  src = fetchurl {
    name = "beegfs-archive-${version}.tar.bz2";
    url = "https://git.beegfs.com/pub/v7/repository/archive.tar.bz2?ref=${version}";
    sha256 = "11wcbm55cwqfiqsb3ni2n9mn1x5bdfs64rjamzr2vm35npy2kv2n";
  };

  nativeBuildInputs = [ which unzip pkgconfig cppunit perl ];

  buildInputs = [
    gcc8
    libuuid
    attr
    xfsprogs
    zlib
    openssl
    sqlite
    rdma-core
    openssh
    gfortran
    influxdb
    curl
    rdma-core
  ];

  hardeningDisable = [ "format" ]; # required for building beeond

  postPatch = ''
    patchShebangs ./
    find -type f -name Makefile -exec sed -i "s:/bin/bash:${stdenv.shell}:" \{} \;
    find -type f -name Makefile -exec sed -i "s:/bin/true:true:" \{} \;
    find -type f -name "*.mk" -exec sed -i "s:/bin/true:true:" \{} \;
  '';

  buildPhase = ''
    make BEEGFS_OPENTK_IBVERBS=1 \
    KDIR=${linux.dev}/lib/modules/${linux.modDirVersion}/build \
    ''${enableParallelBuilding:+-j''${NIX_BUILD_CORES} \
    -l''${NIX_BUILD_CORES}}
  '';

  enableParallelBuilding = true;

  installPhase = ''
    binDir=$out/bin
    docDir=$out/share/doc/beegfs
    includeDir=$out/include/beegfs
    libDir=$out/lib
    libDirPkg=$out/lib/beegfs
    mkdir -p $binDir $libDir $libDirPkg $docDir $includeDir
    cp ctl/build/beegfs-ctl $binDir
    cp fsck/build/beegfs-fsck $binDir
    cp utils/scripts/beegfs-check-servers $binDir
    cp utils/scripts/beegfs-df $binDir
    cp utils/scripts/beegfs-net $binDir
    cp helperd/build/beegfs-helperd $binDir
    cp helperd/build/dist/etc/beegfs-helperd.conf $docDir
    cp client_module/build/dist/sbin/beegfs-setup-client $binDir
    cp client_module/build/dist/etc/beegfs-client.conf $docDir
    cp meta/build/beegfs-meta $binDir
    cp meta/build/dist/sbin/beegfs-setup-meta $binDir
    cp meta/build/dist/etc/beegfs-meta.conf $docDir
    cp mgmtd/build/beegfs-mgmtd $binDir
    cp mgmtd/build/dist/sbin/beegfs-setup-mgmtd $binDir
    cp mgmtd/build/dist/etc/beegfs-mgmtd.conf $docDir
    cp storage/build/beegfs-storage $binDir
    cp storage/build/dist/sbin/beegfs-setup-storage $binDir
    cp storage/build/dist/etc/beegfs-storage.conf $docDir
    cp client_devel/build/dist/usr/share/doc/beegfs-client-devel/examples/* $docDir
    cp -r client_devel/include/* $includeDir
  '';

  doCheck = true;

  # checkPhase = ''
  #   LD_LIBRARY_PATH=$LD_LIBRARY_PATH:`pwd`/opentk_lib/build/ \
  #     common/build/test-runner --text
  # '';

  meta = with stdenv.lib; {
    description = "High performance distributed filesystem with RDMA support";
    homepage = "https://www.beegfs.io";
    platforms = [ "i686-linux" "x86_64-linux" ];
    license = {
      fullName = "BeeGFS_EULA";
      url = "https://www.beegfs.io/docs/BeeGFS_EULA.txt";
      free = false;
    };
    maintainers = with maintainers; [ "juselius" ];
  };
}
