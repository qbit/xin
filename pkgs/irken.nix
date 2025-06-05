{
  lib,
  mkTclDerivation,
  fetchFromGitHub,
  bwidget,
  libnotify,
  tclcurl,
  tcltls,
  tk,
}:

mkTclDerivation {

  pname = "irken";
  version = "2024-11-19";

  src = fetchFromGitHub {
    owner = "dlowe-net";
    repo = "irken";
    rev = "2196a9c0d4549d43972fbc56ef38a06b2b569c4f";
    hash = "sha256-vK7eoJDMh9D/+BJMyGaDAsQSC8ENgu4D9ZNV5d1zLr0=";
  };

  buildInputs = [
    bwidget
    libnotify
    tclcurl
    tcltls
    tk
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp irken.tcl $out/bin/irken
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/dlowe-net/irken";
    license = licenses.asl20;
    maintainers = with maintainers; [ qbit ];
  };
}
