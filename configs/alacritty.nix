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
  script = pkgs.writeScriptBin "alacritty-etc" ''
    ${pkgs.alacritty}/bin/alacritty --config-file ${settingsFile}
  '';
in
{
  config = {
    nixpkgs.overlays = [
      (self: super: {
        alacritty = super.alacritty.overrideAttrs (old: {
          postInstall = old.postInstall + ''
            ${super.gnused}/bin/sed -i 's#^Exec=alacritty#Exec=alacritty --config-file ${settingsFile}#g' \
              extra/linux/Alacritty.desktop
            install -D extra/linux/Alacritty.desktop -t $out/share/applications/
          '';
        });
      })
    ];
    environment = {
      systemPackages = [
        script
      ];
      etc = {
        "xdg/alacritty/alacritty.toml".text = builtins.readFile settingsFile;
      };
    };
  };
}
