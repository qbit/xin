{ lib, ... }:
let
  tidal-hifi = _: super: {
    tidal-hifi = super.tidal-hifi.overrideAttrs (_: rec {
      version = "5.1.0";

      src = super.fetchurl {
        url =
          "https://github.com/Mastermindzh/tidal-hifi/releases/download/${version}/tidal-hifi_${version}_amd64.deb";
        sha256 = "sha256-IaSgul2L0L343TVT3ujgBoMt6tITwjJaBNOVJPCBDtI=";
      };
      postFixup = ''
        makeWrapper $out/opt/tidal-hifi/tidal-hifi $out/bin/tidal-hifi \
          --prefix LD_LIBRARY_PATH : "${
            lib.makeLibraryPath super.tidal-hifi.buildInputs
          }" \
          "''${gappsWrapperArgs[@]}"
        substituteInPlace $out/share/applications/tidal-hifi.desktop \
          --replace "/opt/tidal-hifi/tidal-hifi" "tidal-hifi"
      '';
    });
  };
in tidal-hifi
