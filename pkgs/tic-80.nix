{ lib
, stdenv
, cmake
, pkg-config
, curl
, lua
, mruby
, SDL
, SDL_mixer
, python3
, xorg
, ...
}:
stdenv.mkDerivation {
  pname = "tic-80";
  version = "1.1.2837";

  src = builtins.fetchGit {
    url = "https://github.com/nesbox/TIC-80";
    rev = "be42d6f146cfa520b9b1050feba10cc8c14fb3bd";
    allRefs = true;
    submodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    curl.dev
    lua
    mruby
    SDL
    SDL_mixer
    python3
    xorg.libXext
  ];

  meta = with lib; {
    description = "Fantasy computer for making, playing and sharing games.";
    homepage = "https://tic80.com";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ qbit ];
  };
}
