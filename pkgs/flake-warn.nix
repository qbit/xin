{
  stdenv,
  lib,
  jq,
  nix,
  coreutils,
  writeTextFile,
  ...
}:
stdenv.mkDerivation rec {
  pname = "flake-warn";
  version = "1.0.0";

  buildCommand = ''
    install -Dm755 $script $out/bin/${pname}
  '';

  script = writeTextFile {
    name = pname;
    text = ''
      #!/bin/sh

      BOLD=$(tput bold)
      NORMAL=$(tput sgr0)

      # TODO: Use the following for more accurate, to-the-input results:
      # nix flake metadata --json | jq -r '.locks.nodes[] | select(.original.repo == "nixpkgs" and .original.owner == "NixOS") | [ .original.ref, .locked.lastModified ] | join("^")'

      FLAKE_EPOCH=$(${nix}/bin/nix flake metadata --json | ${jq}/bin/jq .lastModified)
      NOW_EPOCH=$(${coreutils}/bin/date +"%s")

      EPOCH_DIFF=$((NOW_EPOCH - FLAKE_EPOCH))

      if [ $EPOCH_DIFF -gt $((60480 * 5)) ]; then
      	echo
      	echo "$BOLDWARNING: inputs haven't been updated in $((EPOCH_DIFF / 86400)) days!$NORMAL"
      	echo
      fi
    '';
  };
  meta = {
    description = "script to warn when flake inputs are out of date";
    homepage = "https://codeberg.org/qbit/xin";
    license = lib.licenses.isc;
    maintainer = with lib.maintainers; [ qbit ];
    mainProgram = "flake-warn";
  };
}
