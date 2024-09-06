{ config
, pkgs
, isUnstable
, lib
, ...
}:
let
  myEmacs = pkgs.callPackage ../pkgs/emacs.nix { inherit isUnstable; };
  editorScript = pkgs.writeShellScriptBin "emacseditor" ''
    if [ -z "$1" ]; then
      exec ${myEmacs}/bin/emacsclient --create-frame --alternate-editor ${myEmacs}/bin/emacs
    else
      exec ${myEmacs}/bin/emacsclient --alternate-editor ${myEmacs}/bin/emacs "$@"
    fi
  '';
in
{
  config = {
    environment = {
      variables.EDITOR = lib.mkOverride 900 "emacseditor";
      systemPackages = with pkgs; [
        (aspellWithDicts (dicts: with dicts; [ en en-computers es de ]))
        go-font
        texlive.combined.scheme-full

        myEmacs
        editorScript
      ];
    };
  };
}
