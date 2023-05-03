{ pkgs, ... }:

let
  tomlFmt = pkgs.formats.toml {};
  helixConfig = tomlFmt.generate "helix-config.toml" {
    theme = "acme";
    editor = {
      mouse = false;
    };
  };
  helixBin = "${pkgs.helix}/bin/hx";
in pkgs.writeScriptBin "hx" ''
  ${helixBin} -c ${helixConfig} $@
''
