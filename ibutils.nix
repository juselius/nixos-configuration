{ stdenv, fetchurl, opensm, tk, tcl, libibumad, which, perl }:

stdenv.mkDerivation rec {
  version = "1.5.7";
  name = "ibutils-${version}";

  src = fetchurl {
    url = "https://www.openfabrics.org/downloads/ibutils/ibutils-1.5.7-0.2.gbd7e502.tar.gz";
    sha256 = "00x7v6cf8l5y6g9xwh1sg738ch42fhv19msx0h0090nhr0bv98v7";
  };

  enableParallelBuilding = true;

  buildInputs = with stdenv; [ opensm libibumad tk tcl ];
  nativeBuildInputs = [ which perl ];

  configureFlags = [ "--with-osm=${opensm}" "--with-tk-lib=${tk}" "--with-tcl-lib=${tcl}" ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -Wformat=0 -Wno-format-security";
  '';

  meta = {
    description = "infiband utilities";
    homepage = https://www.openfabrics.org/downloads/ibutils/;
    maintainers = [ ];
    platforms = stdenv.lib.platforms.all;
  };
}
