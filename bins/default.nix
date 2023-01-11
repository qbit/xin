{ pkgs, lib, isUnstable, ... }:
let
  gosignify = pkgs.callPackage ../pkgs/gosignify.nix { inherit isUnstable; };

  ix = pkgs.writeScriptBin "ix" (import ./ix.nix { inherit (pkgs) perl; });
  checkRestart = pkgs.writeScriptBin "check-restart"
    (import ./check-restart.nix { inherit (pkgs) perl; });
  xinStatus = pkgs.writeScriptBin "xin-status"
    (import ./xin-status.nix { inherit (pkgs) perl perlPackages; });

  sfetch = pkgs.writeScriptBin "sfetch" (import ./sfetch.nix {
    inherit gosignify;
    inherit (pkgs) curl;
  });
  rpr = pkgs.writeScriptBin "rpr" (import ./rpr.nix {
    inherit (pkgs) _1password;
    inherit (pkgs) gh;
    inherit (pkgs) tea;
  });

in {
  environment.systemPackages = with pkgs; [
    checkRestart
    ix
    #rpr
    sfetch
    xclip
    xinStatus
  ];
  environment.etc = {
    "signify/openbsd-72-base.pub".text =
      builtins.readFile ./pubs/openbsd-72-base.pub;
    "signify/openbsd-72-fw.pub".text =
      builtins.readFile ./pubs/openbsd-72-fw.pub;
    "signify/openbsd-72-pkg.pub".text =
      builtins.readFile ./pubs/openbsd-72-pkg.pub;
    "signify/openbsd-72-syspatch.pub".text =
      builtins.readFile ./pubs/openbsd-72-syspatch.pub;
  };
}
