{ lib, mkTclDerivation, fetchFromGitHub, tcltls, bwidget, tk }:

mkTclDerivation {

  pname = "irken";
  version = "2024-11-16";

  src = fetchFromGitHub {
    owner = "dlowe-net";
    repo = "irken";
    rev = "659a185de9b6c5a48f46a4535911123c91c7c866";
    hash = "sha256-Sti6id6aT9QFug6QkNPHf4LisBCuF4LqLNlNEaIUNI8=";
  };

  buildInputs = [
    tcltls
    bwidget
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
