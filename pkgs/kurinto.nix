{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation rec {
  pname = "kurinto";
  version = "2.197";

  src = fetchzip {
    url = "https://www.kurinto.com/zip/Kurinto_v${version}_Full.zip";
    stripRoot = true;
    sha256 = "sha256-ofROCmd4TeYmIfkbNGpg4qO4E80noAo+4LGDC/y90Dk=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    mv */Fonts/*.ttf $out/share/fonts/truetype
  '';

  dontBuild = true;

  meta = with lib; {
    homepage = "https://www.kurinto.com/index.htm";
    description =
      "a large collection of free fonts that include most of the characters in every human language";
    license = licenses.ofl;
    maintainers = with maintainers; [ qbit ];
    platforms = lib.platforms.all;
    hydraPlatform = [ ];
  };
}
