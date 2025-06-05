{
  lib,
  fetchurl,
  stdenv,
  unzip,
  ...
}:
stdenv.mkDerivation rec {
  pname = "hammerspoon";
  version = "0.9.97";

  src = fetchurl {
    name = "Hammerspoon-${version}.zip";
    url = "https://github.com/Hammerspoon/hammerspoon/releases/download/${version}/Hammerspoon-${version}.zip";
    hash = "sha256-7y7YZYmB+KMVdHZXLdic5JanXQl6vtaTmqmvkFa8UTM=";
  };

  buildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -R ../*.app $out/Applications
  '';

  meta = {
    description = "Staggeringly powerful macOS desktop automation with Lua";
    homepage = "http://www.hammerspoon.org/";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
  };
}
