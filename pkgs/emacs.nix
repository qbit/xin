{ emacsWithPackagesFromUsePackage
, pkgs
, ...
}:
let
  emacsPkg =
    if (pkgs.system == "x86_64-linux") then
      pkgs.emacs # TODO, switch back to pgtk when it stops crashing
    else
      pkgs.emacs;
in
emacsWithPackagesFromUsePackage {
  config = ../configs/emacs.org;

  alwaysEnsure = true;
  alwaysTangle = true;

  defaultInitFile = true;
  package = emacsPkg;

  override = epkgs: epkgs // {
    ollama = pkgs.callPackage ../pkgs/ollama-el.nix {
      inherit (pkgs) fetchFromGitHub;
      inherit (epkgs) trivialBuild;
    };
  };
}
