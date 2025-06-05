{
  lib,
  stdenv,
  fetchurl,
  pkgs,
  ...
}:
stdenv.mkDerivation rec {
  pname = "icbirc";
  version = "2.1";

  src = fetchurl {
    url = "http://www.benzedrine.ch/icbirc-${version}.tar.gz";
    sha256 = "sha256-aDk0TZPABNqX7Gu12AWh234Kee/DhwRFeIBDYnFiu7E=";
  };

  patches = [ ./icbirc.diff ];

  buildInputs = with pkgs; [
    libbsd
    bsdbuild
    bmake
  ];

  meta = with lib; {
    description = "proxy IRC client with ICB server";
    longDescription = ''
      icbirc is a proxy that allows to connect an IRC client to an ICB server.
    '';
    homepage = "http://www.benzedrine.ch/icbirc.html";
    license = licenses.bsd2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ qbit ];
  };
}
