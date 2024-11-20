{ lib, mkTclDerivation, fetchFromGitHub, tcltls, bwidget, tk, libnotify }:

mkTclDerivation {

  pname = "irken";
  version = "2024-11-19";

  src = fetchFromGitHub {
    owner = "dlowe-net";
    repo = "irken";
    rev = "66bfa30b6933f5347bb301b8e5ea63eef5d446a6";
    hash = "sha256-rPpmcaAeEVFhT2EERYXsXVsj+w//bBX+gJHRSa3mph0=";
  };

  buildInputs = [
    tcltls
    bwidget
    tk
    libnotify
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
