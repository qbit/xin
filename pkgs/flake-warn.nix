{ stdenv
, lib
, substituteAll
, jq
, nix
, coreutils
, ...
}:
stdenv.mkDerivation rec {
  pname = "flake-warn";
  version = "1.0.0";

  buildCommand = ''
    install -Dm755 $script $out/bin/${pname}
  '';

  script = substituteAll {
    src = ./flake-warn.sh;
    isExecutable = true;
    inherit jq nix coreutils;
    inherit (stdenv) shell;
  };

  meta = {
    description = "script to warn when flake inputs are out of date";
    homepage = "https://codeberg.org/qbit/xin";
    license = lib.licenses.isc;
    maintainer = with lib.maintainers; [ qbit ];
    mainProgram = "flake-warn";
  };
}
