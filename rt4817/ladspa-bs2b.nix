{ stdenv, fetchurl, pkg-config, libbs2b, ladspa-header, lib }:

stdenv.mkDerivation rec {
  pname = "ladspa-bs2b";
  version = "0.9.1";

src = fetchurl {
  url = "mirror://sourceforge/bs2b/plugins/LADSPA%20plugin/${version}/${pname}-${version}.tar.gz";

  sha256 = "sha256-4km0ZQWygESLxP5m1GT23GsS/KvvsPVSmkWtINeNiqw=";
};

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libbs2b ladspa-header ];

  configureFlags = [
    "--with-ladspa-dir=${placeholder "out"}/lib/ladspa"
  ];

  meta = {
    description = "BS2B LADSPA plugin";
    license = lib.licenses.gpl2Plus;
  };
}
