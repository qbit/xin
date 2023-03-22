{ lib, stdenv, fetchFromGitHub, pkgs, go-font, ... }:

stdenv.mkDerivation rec {
  pname = "zutty";
  version = "0.14";

  src = fetchFromGitHub {
    owner = "tomszilagyi";
    repo = "zutty";
    rev = version;
    sha256 = "sha256-b/q7hIi/U/GkKo+MIFX2wWnHZAy5rQGXNul3I1pxo1Q=";
  };

  patches = [ ./zutty_go.diff ];

  nativeBuildInputs = with pkgs; [
    gcc
    pkg-config
    python3
    wafHook
    xorg.libXmu
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
    homepage = "https://tomscii.sig7.se/zutty/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ qbit ];
  };
}

