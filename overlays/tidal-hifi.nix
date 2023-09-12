let
  tidal-hifi = _: super: {
    tidal-hifi = super.tidal-hifi.overrideAttrs (_: rec {
      version = "5.3.0";

      src = super.fetchurl {
        url = "https://github.com/Mastermindzh/tidal-hifi/releases/download/${version}/tidal-hifi_${version}_amd64.deb";
        sha256 = "sha256-YGSHEvanWek6qiWvKs6g+HneGbuuqJn/DBfhawjQi5M=";
      };
    });
  };
in
tidal-hifi
