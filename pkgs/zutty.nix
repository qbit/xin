{
  lib,
  stdenv,
  fetchurl,
  pkgs,
  go-font,
  ...
}:
stdenv.mkDerivation rec {
  pname = "zutty";
  version = "unstable-2024-01-10";
  rev = "8453f9f251dfcc14e0ba2d819b5367cbc5c9c47e";

  src = fetchurl {
    url = "https://git.hq.sig7.se/zutty.git/snapshot/${rev}.tar.gz";
    hash = "sha256-iRAr1QEZj1UvKBHRJmhZkbEq/Uq0gEAMNTtCpx/nz5w=";
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

  buildInputs = with pkgs; [
    freetype
    fontconfig
  ];

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
    description = "X terminal emulator rendering through OpenGL ES Compute Shaders";
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
