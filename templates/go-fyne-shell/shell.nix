{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  shellHook = ''
    export NO_COLOR=true
    export PS1="\u@\h:\w; "
  '';

  nativeBuildInputs = with pkgs.buildPackages; [
    alsa-lib
    glfw
    go
    libxkbcommon
    pkg-config
    wayland
    xorg.libXcursor
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXxf86vm
    xorg.xinput
  ];
}
