{
  pkgs,
  config,
  isUnstable,
  ...
}:
let
  mkPubs = ver: {
    "signify/openbsd-${toString ver}-base.pub".text =
      builtins.readFile ./pubs/openbsd-${toString ver}-base.pub;
    "signify/openbsd-${toString ver}-fw.pub".text =
      builtins.readFile ./pubs/openbsd-${toString ver}-fw.pub;
    "signify/openbsd-${toString ver}-pkg.pub".text =
      builtins.readFile ./pubs/openbsd-${toString ver}-pkg.pub;
    "signify/openbsd-${toString ver}-syspatch.pub".text =
      builtins.readFile ./pubs/openbsd-${toString ver}-syspatch.pub;
  };
  gosignify = pkgs.callPackage ../pkgs/gosignify.nix { inherit isUnstable; };

  ix = pkgs.writeScriptBin "ix" (import ./ix.nix { inherit (pkgs) perl; });
  checkRestart = pkgs.writeScriptBin "check-restart" (
    import ./check-restart.nix { inherit (pkgs) perl; }
  );
  sfetch = pkgs.writeScriptBin "sfetch" (
    import ./sfetch.nix {
      inherit gosignify;
      inherit (pkgs) curl;
    }
  );
  genPatches = pkgs.callPackage ./gen-patches.nix { };
  upgrade-pg = pkgs.writeScriptBin "upgrade-pg" (
    import ./upgrade-pg.nix {
      inherit pkgs;
      inherit config;
    }
  );
in
{
  environment.systemPackages =
    with pkgs;
    [
      checkRestart
      genPatches
      ix
      sfetch
      xclip
    ]
    ++ (if config.services.postgresql.enable then [ upgrade-pg ] else [ ]);
  environment.etc =
    (mkPubs 68)
    // (mkPubs 69)
    // (mkPubs 70)
    // (mkPubs 71)
    // (mkPubs 72)
    // (mkPubs 73)
    // (mkPubs 74)
    // (mkPubs 75)
    // (mkPubs 76)
    // (mkPubs 77)
    // (mkPubs 78)
    // (mkPubs 79);
}
