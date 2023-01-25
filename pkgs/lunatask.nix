{ lib, fetchurl, appimageTools, makeDesktopItem, desktop-file-utils, ... }:

let
  name = "lunatask";
  version = "1.5.12";

  src = fetchurl {
    name = "Lunatask-${version}";
    url = "https://lunatask.app/download/Lunatask-${version}.AppImage";
    sha256 = "sha256-Aw8w4RmVIsZXUtIn8A8VtBLzX+xVFyQvppSpWZJvTpA=";
  };

  appimageContents = appimageTools.extract { inherit name src; };

in appimageTools.wrapType2 {
  inherit name src;

  extraInstallCommands = ''
    cp -r ${appimageContents}/* $out
  '';

  #extraPkgs = pkgs: with pkgs; [ ];
}
