{
  emacsWithPackagesFromUsePackage,
  pkgs,
  ...
}:
let
  emacsPkg = if (pkgs.system == "x86_64-linux") then pkgs.emacs-git-pgtk else pkgs.emacs;
in
emacsWithPackagesFromUsePackage {
  config = ../configs/emacs.org;

  alwaysEnsure = true;
  alwaysTangle = true;

  defaultInitFile = true;
  package = emacsPkg;
}
