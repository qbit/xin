{ lib
, stdenv
, fetchFromGitHub
, pkgs
, ...
}:
stdenv.mkDerivation rec {
  pname = "tic-80";
  version = "1.1.2837";

  src = fetchFromGitHub {
    owner = "nesbox";
    repo = "TIC-80";
    rev = "v${version}";
    sha256 = "";
  };

  nativeBuildInputs = with pkgs; [
    gcc
    pkg-config
    SDL2
    ruby
    lua
  ];

  meta = with lib; {
    description = "Fantasy computer for making, playing and sharing games.";
    homepage = "https://tic80.com";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ qbit ];
  };
}
