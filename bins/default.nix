{ pkgs, lib, isUnstable, ... }:
let
  gosignify = pkgs.callPackage ../pkgs/gosignify.nix { };

  ix = pkgs.writeScriptBin "ix" (import ./ix.nix { inherit (pkgs) perl; });
  checkRestart = pkgs.writeScriptBin "check-restart"
    (import ./check-restart.nix { inherit (pkgs) perl; });

  sfetch = pkgs.writeScriptBin "sfetch"
    (import ./sfetch.nix { inherit gosignify; inherit (pkgs) curl; });

in {
  environment.systemPackages = with pkgs; [ ix sfetch xclip checkRestart ];
  environment.etc = {
    "signify/openbsd-72-base.pub".text = builtins.readFile ./pubs/openbsd-72-base.pub;
    "signify/openbsd-72-fw.pub".text = builtins.readFile ./pubs/openbsd-72-fw.pub;
    "signify/openbsd-72-pkg.pub".text = builtins.readFile ./pubs/openbsd-72-pkg.pub;
    "signify/openbsd-72-syspatch.pub".text = builtins.readFile ./pubs/openbsd-72-syspatch.pub;
  };
}
