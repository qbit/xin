{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  profile = {
    Appearance = {
      AntiAliasFonts = true;
      BoldIntense = true;
      ColorScheme = "BlackOnLightYellow";
      Font = "Go Mono,10,-1,5,50,0,0,0,0,0";
      UseFontLineCharacters = false;
    };
    General = {
      Name = "ARST";
      Parent = "FALLBACK/";
    };

    "Interaction Options" = {
      AutoCopySelectedText = true;
      CopyTextAsHTML = false;
    };

    "Terminal Features" = {
      BellMode = 3;
    };
  };
  settings = {
    "Desktop Entry" = {
      DefaultProfile = "${profile.General.Name}.profile";
    };
    MainWindow = {
      MenuBar = "Disabled";
      StatusBar = "Disabled";
      ToolBarsMovable = "Disabled";
    };
  };
  settingsFormat = pkgs.formats.ini { };
  settingsFile = settingsFormat.generate "konsolerc" settings;
  profileFile = settingsFormat.generate "${profile.General.Name}.profile" profile;

  profilePkg = pkgs.stdenv.mkDerivation {
    name = "konsole-profile";
    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/share/konsole
      cp ${profileFile} "$out/share/konsole/${profile.General.Name}.profile"
    '';
  };
in
{
  config = mkIf config.kde.enable {
    environment = {
      systemPackages = [
        profilePkg
      ];
      etc = {
        "xdg/konsolerc".text = builtins.readFile settingsFile;
      };
    };
    fonts = {
      packages = [ pkgs.go-font ];
    };
  };
}
