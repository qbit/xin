{ lib, fetchurl, appimageTools, makeDesktopItem, isUnstable, desktop-file-utils
, ... }:

let
  name = "cinny-desktop";
  version = "2.0.4";

  src = fetchurl {
    name = "cinny_${version}_amd64.AppImage";
    url =
      "https://github.com/cinnyapp/cinny-desktop/releases/download/v${version}/cinny_${version}_amd64.AppImage";
    sha256 = "sha256-9ZQyVcTsHja67DhuIyniTK/xr0C6qN7fiCmjt8enUd8=";
  };

  appimageContents = appimageTools.extract { inherit name src; };

in appimageTools.wrapType2 rec {
  inherit name src;

  extraInstallCommands = ''
    cp -r ${appimageContents}/* $out
    cd $out
    chmod -R +w $out

    ${desktop-file-utils}/bin/desktop-file-install --dir $out/share/applications \
      --set-key Exec --set-value ${name} "cinny.desktop"

    mv usr/bin/cinny $out/${name}
    #mv usr/share share

    rm -rf usr/lib/* AppRun* *.desktop
  '';

  extraPkgs = pkgs:
    with pkgs; [
      atk
      avahi
      brotli
      cairo
      fontconfig
      freetype
      fribidi
      glew-egl
      gobject-introspection
      gst_all_1.gstreamer
      harfbuzz
      icu
      libdrm
      libGLU
      libgpg-error
      librsvg
      libthai
      pango
      xorg.libX11
      xorg.libxcb
      zlib
    ];
}
