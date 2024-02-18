{ pkgs, ... }:
let
  settings = {
    font = {
      normal = {
        family = "Go Mono";
      };
      size = 6;
    };

    colors = {
      primary = {
        background = "#ffffea";
        foreground = "#000000";
      };
    };
  };
  settingsFormat = pkgs.formats.toml { };
  settingsFile = settingsFormat.generate "alacritty.toml" settings;
in
{
  config = {
    environment = {
      etc = {
        "xdg/alacritty/alacritty.toml".text = builtins.readFile settingsFile;
      };
    };
    fonts = {
      packages = with pkgs; [ go-font ];
    };
  };
}
