{ lib
, stdenv
, fetchFromGitHub
, pkgs
, ...
}:
stdenv.mkDerivation {
  pname = "mvoice";
  version = "unstable-2023-05-30";

  src = fetchFromGitHub {
    owner = "n7tae";
    repo = "mvoice";
    rev = "8e0a9fb350f8308d7ee7e07e3cc48e7c33a7be64";
    sha256 = "sha256-DNCF/m56owu8DYcv2lLxUZ+mVpmivXbPjBFE2V/23pE=";
  };

  nativeBuildInputs = with pkgs; [
    alsa-lib
    curl
    fltk
    gcc
    gettext
    gnutls
    msgpack
    opendht
    paprefs
    pavucontrol
    pulseaudio
    fmt.dev
  ];

  prePatch = ''
    substituteInPlace Makefile \
      --replace "/bin/cp" "cp"
    substituteInPlace Makefile \
      --replace "/bin/rm" "rm"
  '';

  preBuild = ''
    export HOME=$out
  '';

  meta = with lib; {
    description = "A prototype M17 voice application for ham radio";
    homepage = "https://github.com/n7tae/mvoice";
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ qbit ];
  };
}
