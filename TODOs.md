# Example of automated checks from Lily Foster in the NixOS matrix room.

   checks = with unstable.lib;
     foldl' recursiveUpdate { } (mapAttrsToList (name: system: {
       "${system.pkgs.stdenv.hostPlatform.system}"."${name}" =
         system.config.system.build.toplevel;
     }) self.nixosConfigurations);
