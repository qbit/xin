{
  pkgs,
  linkFarm,
  ...
}:
let
  tomlFmt = pkgs.formats.toml { };
  helixBin = "${pkgs.helix}/bin/hx";

  helixConfig = tomlFmt.generate "config.toml" {
    theme = "acme-nobg";
    editor = {
      mouse = false;
      cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };
      lsp = {
        auto-signature-help = false;
      };
    };
  };

  helixTheme = tomlFmt.generate "acme-nobg.toml" {
    inherits = "acme";

    "ui.background" = "default";
    "ui.linenr" = "default";
    "ui.linenr.selected" = "#DEDEFF";
  };

  xdgDir = linkFarm "helix-config" [
    {
      name = "helix/config.toml";
      path = helixConfig;
    }
    {
      name = "helix/themes/acme-nobg.toml";
      path = helixTheme;
    }
  ];
in
pkgs.writeScriptBin "hx" ''
  # Conf:  ${helixConfig}
  # Theme:  ${helixTheme}

  env XDG_CONFIG_HOME="${xdgDir}" ${helixBin} "$@"
''
