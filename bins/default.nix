{ pkgs, lib, isUnstable, ... }:
let
  ix = pkgs.writeScriptBin "ix" (import ./ix.nix { inherit (pkgs) perl; });
  sfetch = pkgs.writeScriptBin "sfetch"
    (import ./sfetch.nix { inherit (pkgs) minisign curl; });
  checkRestart = pkgs.writeScriptBin "check-restart"
    (import ./check-restart.nix { inherit (pkgs) perl; });
in { environment.systemPackages = with pkgs; [ ix sfetch xclip checkRestart ]; }
