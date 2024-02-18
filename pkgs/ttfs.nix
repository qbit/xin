{
  stdenv,
  lib,
  fetchgit,
  gnumake,
  pkg-config,
  SDL2,
  SDL2_ttf,
}:
stdenv.mkDerivation {
  pname = "ttfs";
  version = "2023-03-27";

  src = fetchgit {
    url = "https://git.sr.ht/~ft/ttfs";
    rev = "c672c1919865fe26e2bd50ea31920117d0db6b09";
    hash = "sha256-VHUlfgF8jzGmLO2gxuHFDoKqF92c4Tae7x+8KK1xnug=";
  };

  buildInputs = [ gnumake ];

  nativeBuildInputs = [
    pkg-config
    SDL2
    SDL2_ttf
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ttfs $out/bin
  '';

  meta = {
    description = "TTF/OTF/BDF→Plan9Font converter";
    homepage = "https://git.sr.ht/~ft/ttfs";
    license = lib.licenses.publicDomain;
    maintainer = with lib.maintainers; [ qbit ];
    mainProgram = "ttfs";
  };
}
