# https://github.com/NixOS/nixpkgs/pull/179022
{ lib
, stdenv
, fetchFromSourcehut
, desktop-file-utils
, glib
, gobject-introspection
, gtk3
, gtk-layer-shell
, meson
, ninja
, pkg-config
, python3
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "hiprompt-gtk-py";
  version = "unstable-2023-01-23";

  src = fetchFromSourcehut {
    name = pname + "-src";
    owner = "~sircmpwn";
    repo = pname;
    rev = "8d6ef1d042ec2731f84245164094e622f4be3f2d";
    hash = "sha256-W2oDen9XkvoGOX9mshvUFBdkCGTr4SSTqQRDzayi2hc=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    glib
    meson
    ninja
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    glib
    gobject-introspection
    gtk3
    gtk-layer-shell
    (python3.withPackages (pp: with pp; [
      pygobject3
    ]))
  ];

  meta = with lib; {
    homepage = "https://git.sr.ht/~sircmpwn/hiprompt-gtk-py";
    description = "A GTK+ Himitsu prompter for Wayland";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ auchter ];
    platforms = platforms.linux;
  };
}

