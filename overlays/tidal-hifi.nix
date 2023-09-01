let
  tidal-hifi = _: super: {
    tidal-hifi = super.tidal-hifi.overrideAttrs (_: rec {
      version = "5.2.0";

      src = super.fetchurl {
        url = "https://github.com/Mastermindzh/tidal-hifi/releases/download/${version}/tidal-hifi_${version}_amd64.deb";
        sha256 = "sha256-ZdEbGsGt1Z/vve3W/Z6Pw1+m5xoTY/l7Es03yM4T0tE=";
      };
    });
  };
in
  tidal-hifi
