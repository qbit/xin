{ emacsWithPackagesFromUsePackage
, pkgs
, emacsPkg ? pkgs.emacs-pgtk
, ...
}:
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
