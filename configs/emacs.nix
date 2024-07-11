{ emacsWithPackagesFromUsePackage
, pkgs
, emacsPkg ? pkgs.emacs-gtk
, ...
}:
emacsWithPackagesFromUsePackage {
  config = ./emacs.org;

  alwaysEnsure = true;
  alwaysTangle = true;

  defaultInitFile = true;
  package = emacsPkg;
}
