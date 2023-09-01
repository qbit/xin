{
  pkgs,
  isUnstable,
  ...
}: let
  gosignify = pkgs.callPackage ../pkgs/gosignify.nix {inherit isUnstable;};

  ix = pkgs.writeScriptBin "ix" (import ./ix.nix {inherit (pkgs) perl;});
  checkRestart =
    pkgs.writeScriptBin "check-restart"
    (import ./check-restart.nix {inherit (pkgs) perl;});
  xinStatus =
    pkgs.writeScriptBin "xin-status"
    (import ./xin-status.nix {inherit (pkgs) perl perlPackages;});
  tstart =
    pkgs.writeScriptBin "tstart" (import ./tstart.nix {inherit (pkgs) tmux;});
  sfetch = pkgs.writeScriptBin "sfetch" (import ./sfetch.nix {
    inherit gosignify;
    inherit (pkgs) curl;
  });
in {
  environment.systemPackages = with pkgs; [
    checkRestart
    ix
    sfetch
    tstart
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

    "signify/openbsd-73-base.pub".text =
      builtins.readFile ./pubs/openbsd-73-base.pub;
    "signify/openbsd-73-fw.pub".text =
      builtins.readFile ./pubs/openbsd-73-fw.pub;
    "signify/openbsd-73-pkg.pub".text =
      builtins.readFile ./pubs/openbsd-73-pkg.pub;
    "signify/openbsd-73-syspatch.pub".text =
      builtins.readFile ./pubs/openbsd-73-syspatch.pub;
  };
}
