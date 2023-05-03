{ pkgs, ... }:

let
  tomlFmt = pkgs.formats.toml { };
  helixConfig = tomlFmt.generate "helix-config.toml" {
    theme = "acme";
    editor = {
      mouse = false;
      cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };
      lsp = { auto-signature-help = false; };
    };
  };
  helixBin = "${pkgs.helix}/bin/hx";
in pkgs.writeScriptBin "hx" ''
  ${helixBin} -c ${helixConfig} $@
''
