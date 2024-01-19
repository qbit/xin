{ pkgs, ... }:
let
  theme = {
    colors = {
      primary = {
        background = "#ffffea";
        foreground = "#000000";
      };
    };
  };
  themeFormat = pkgs.formats.toml { };
  themeFile = themeFormat.generate "plan9.toml" theme;
  settings = {
    import = [
      "${themeFile}"
    ];

    font = {
      normal = {
        family = "Go";
        style = "Mono";
      };
    };
  };
  settingsFormat = pkgs.formats.toml { };
  settingsFile = settingsFormat.generate "alacritty.toml" settings;
in
{
  config = {
    environment.etc = {
      "alacritty/alacritty.toml".text = builtins.readFile settingsFile;
      "alacritty/theme.yml".text = builtins.readFile themeFile;
    };
  };
}
