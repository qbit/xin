{ pkgs, writeTextFile, ... }:

let
  helixConfig = writeTextFile {
    name = "helix/config.toml";
    text = builtins.readFile ./helix.toml;
  };
  helixBin = "${pkgs.helix}/bin/hx";
in pkgs.writeScriptBin "hx" ''
  ${helixBin} -c ${helixConfig} $@
''
