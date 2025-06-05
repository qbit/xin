{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.xin-monitoring;
  inherit (builtins)
    readFile
    concatStringsSep
    attrValues
    mapAttrs
    replaceStrings
    ;

  nginxCfg = config.services.nginx;
  buildFSChecker =
    fsList:
    (concatStringsSep "\n" (
      attrValues (
        mapAttrs (
          f: v:
          if v.fsType != "sshfs" then
            ''
              check filesystem ${replaceStrings [ "/" ] [ "_" ] f} with path ${f}
                 if space usage > 90% then alert
                 if inode usage > 90% then alert
            ''
          else
            ""
        ) fsList
      )
    ));
  buildNginxChecker =
    vhostList:
    (concatStringsSep "\n" (
      attrValues (
        mapAttrs (f: v: ''
          check host ${f} with address ${f}
              if failed port 80 protocol http then alert
              ${if v.enableACME then "if failed port 443 protocol https then alert" else ""}
        '') vhostList
      )
    ));
  nginxChecks =
    if nginxCfg.enable then
      if config.networking.hostName == "h" then (buildNginxChecker nginxCfg.virtualHosts) else ""
    else
      "";
in
{
  options = {
    services.xin-monitoring = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Monitoring";
      };
      fs = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Create monitoring entry points from `config.fileSystems`.
        '';
      };
      nginx = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Create monitoring entry points from `services.nginx.virtualHosts`.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    sops.secrets = {
      monit_cfg = {
        sopsFile = config.xin-secrets.deploy;
        owner = "root";
        mode = "400";
      };
    };
    services.monit = {
      enable = true;
      config = concatStrings [
        (readFile ./monitrc)
        (optionalString cfg.fs (buildFSChecker config.fileSystems))
        (optionalString cfg.nginx nginxChecks)
      ];
    };
  };
}
