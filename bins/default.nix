{ pkgs, lib, isUnstable, ... }:
let
  ix = pkgs.writeScriptBin "ix" (import ./ix.nix { inherit (pkgs) perl; });
  rage = pkgs.writeScriptBin "rage" (import ./rage.nix { inherit pkgs; });
  sfetch = pkgs.writeScriptBin "sfetch"
    (import ./sfetch.nix { inherit (pkgs) minisign curl; });
  checkRestart = pkgs.writeScriptBin "check-restart"
    (import ./check-restart.nix { inherit (pkgs) perl; });
in {
  environment.systemPackages = with pkgs; [ rage ix sfetch xclip checkRestart ];
}
