{ lib
, fetchurl
, stdenv
, undmg
, ...
}:
stdenv.mkDerivation rec {
  pname = "nheko";
  version = "0.10.0";

  src = fetchurl {
    url = "https://github.com/Nheko-Reborn/nheko/releases/download/v${version}/nheko-v${version}.dmg";
    hash = "sha256-t7evlvb+ueJZhtmt4KrOeXv2BZV8/fY4vj4GAmoCR2w=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -a Nheko.app $out/Applications/
  '';

  meta = {
    description = "Desktop client for Matrix using Qt and C++17";
    homepage = "https://github.com/Nheko-Reborn/nheko";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.darwin;
  };
}
