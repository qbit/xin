{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "kurinto";
  version = "2.197";

  src = fetchzip {
    # Upstream re-rolled the same file name with changes so I am hosting on my site.
    #url = "https://www.kurinto.com/zip/Kurinto_v${version}_Full.zip";
    url = "https://deftly.net/Kurinto_v${version}_Full.zip";
    stripRoot = true;
    sha256 = "sha256-0tr2PyznTnipTVN6ydOxgvmCXj1WA7F696FtDmPBd+A=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    find . -name \*.ttf -exec cp {} $out/share/fonts/truetype/ \;
  '';

  dontBuild = true;

  meta = with lib; {
    homepage = "https://www.kurinto.com/index.htm";
    description = "a large collection of free fonts that include most of the characters in every human language";
    license = licenses.ofl;
    maintainers = with maintainers; [ qbit ];
    platforms = lib.platforms.all;
    hydraPlatform = [ ];
  };
}
