{ lib, stdenv, fetchpatch, fetchFromGitHub, pkgs, go-font, ... }:

stdenv.mkDerivation rec {
  pname = "zutty";
  version = "0.13";

  src = fetchFromGitHub {
    owner = "tomszilagyi";
    repo = "zutty";
    rev = version;
    sha256 = "sha256-1eB5GDhWGwyhiKzxpepzjQ44Co0ZeL9JJI5ppPE1TJw=";
  };

  patches = [
    ./zutty_go.diff
  ];

  nativeBuildInputs = with pkgs; [
    gcc
    pkg-config
    python
    wafHook
    xlibsWrapper
    xorg.libXmu
    #xorg.libXau
    #xorg.libXdmcp
    libGL
  ];

  buildInputs = with pkgs; [ freetype fontconfig ];

  prePatch = ''
  substituteInPlace src/options.h \
    --replace "/usr/share/fonts" "${go-font}/share/fonts"
  '';

  postInstall = ''
    mkdir -p $out/share/applications/
    for size in 16 32 48 64 96 128; do
      mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps/
      cp icons/zutty_''${size}x''${size}.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/zutty.png
    done
    cp icons/zutty.desktop $out/share/applications/
  '';

  meta = with lib; {
    description =
      "X terminal emulator rendering through OpenGL ES Compute Shaders";
    longDescription = ''
      Zutty is a terminal emulator for the X Window System, functionally
      similar to several other X terminal emulators such as xterm, rxvt and
      countless others. It is also similar to other, much more modern,
      GPU-accelerated terminal emulators such as Alacritty and Kitty. What
      really sets Zutty apart is its radically simple, yet extremely
      efficient rendering implementation, coupled with a sufficiently
      complete feature set to make it useful for a wide range of users.
    '';
    homepage = "" "https://tomscii.sig7.se/zutty/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ qbit ];
  };
}

