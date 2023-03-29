{ config, ... }:
let
  inherit (builtins)
    readFile concatStringsSep attrValues mapAttrs replaceStrings;

in {
  config = {
    sops.secrets = {
      monit_cfg = {
        sopsFile = config.xin-secrets.deploy;
        owner = "root";
        mode = "400";
      };
    };
    services.monit = {
      enable = true;
      config = readFile ./monitrc + (concatStringsSep "\n" (attrValues (mapAttrs
        (f: _: ''
          check filesystem ${replaceStrings [ "/" ] [ "_" ] f} with path ${f}
             if space usage > 90% then alert
             if inode usage > 90% then alert
        '') config.fileSystems)));
    };
  };
}
