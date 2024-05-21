{ runCommand
, emacsWithPackagesFromUsePackage
, pkgs
, makeWrapper
, writeTextDir
, emacs
, emacsPkg ? pkgs.emacs-gtk
, isUnstable
, ...
}:
let
  # Generate a .el file from our emacs.org.
  emacsConfig = runCommand "emacsConfig" { } ''
    mkdir -p $out
    cp -v ${./emacs.org} $out/emacs.org
    cd $out
    ${emacs}/bin/emacs --batch -Q -q \
                       --debug-init \
                       -l org emacs.org \
                       -f org-babel-tangle
    if [ $? != 0 ]; then
      echo "Generating failed!"
      exit 1;
    else
      echo "Generated org config!"
    fi
  '';

  # init.el to load my config and other dependencies.
  emacsInit = writeTextDir "share/emacs/site-lisp/init.el" ''
    (message "Loading my 'emacs.org' config from: ${emacsConfig}")
    (load "${emacsConfig}/emacs.el")
  '';
  emacsInitDir = "${emacsInit}/share/emacs/site-lisp";

  unstablePkgs = if isUnstable then with pkgs; [ htmx-lsp ] else [ ];

  # Binaries that are needed in emacs
  emacsDepList = with pkgs; [
    deno
    elmPackages.elm
    elmPackages.elm-format
    elmPackages.elm-language-server
    go-font
    gopls
    gotools
    graphviz
    ispell
    luaformatter
    luajitPackages.lua-lsp
    nixpkgs-fmt
    nodePackages.prettier
    nodePackages.typescript-language-server
    nodejs
    perlPackages.PLS
    rubyPackages.solargraph
    sleek
    sumneko-lua-language-server
    texlive.combined.scheme-full
    tree-sitter
  ] ++ unstablePkgs;
in
emacsWithPackagesFromUsePackage {
  config = ./emacs.org;

  alwaysEnsure = true;
  alwaysTangle = true;

  package = emacsPkg.overrideAttrs (oa: {
    nativeBuildInputs = oa.nativeBuildInputs ++ [ makeWrapper emacsConfig ];
    postInstall = ''
      ${oa.postInstall}
      wrapProgram $out/bin/emacs \
        --prefix PATH : ${pkgs.lib.makeBinPath emacsDepList} \
        --add-flags '--init-directory ${emacsInitDir}'
    '';
  });
}
