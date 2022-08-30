{ lib, mkDerivation, fetchFromGitHub, kcoreaddons, kwindowsystem
, plasma-framework, systemsettings }:

mkDerivation rec {
  pname = "tile-gaps";
  version = "7.1";

  src = fetchFromGitHub {
    owner = "nclarius";
    repo = "tile-gaps";
    rev = "window-gaps_v${version}";
    sha256 = "sha256-7tW098kP50rQApn0SW538NrJT0YArpkw/njYWavMvLo=";
  };

  buildInputs = [ kcoreaddons kwindowsystem plasma-framework systemsettings ];

  dontBuild = true;

  # 1. --global still installs to $HOME/.local/share so we use --packageroot
  # 2. plasmapkg2 doesn't copy metadata.desktop into place, so we do that manually
  installPhase = ''
    runHook preInstall

    plasmapkg2 --type kwinscript --install ${src} --packageroot $out/share/kwin/scripts
    install -Dm644 ${src}/metadata.desktop $out/share/kservices5/tilegaps.desktop

    runHook postInstall
  '';

  meta = with lib; {
    description = ''
    KWin script to add space around windows touching a screen edge or other window
    '';
    license = licenses.gpl3;
    maintainers = with maintainers; [ qbit ];
    inherit (src.meta) homepage;
    inherit (kwindowsystem.meta) platforms;
  };
}
