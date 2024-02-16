{ pkgs, ... }:
let
  settings = {
    "MainWindow" = {
      MenuBar = "Disabled";
      StatusBar = "Disabled";
      ToolBarsMovable = "Disabled";
    };
  };
  settingsFormat = pkgs.formats.ini { };
  settingsFile = settingsFormat.generate "konsolerc" settings;
in
{
  config = {
    environment = {
      systemPackages = [ ];
      etc = {
        "xdg/konsolerc".text = builtins.readFile settingsFile;
      };
    };
    fonts = { packages = [ pkgs.go-font ]; };
  };
}
