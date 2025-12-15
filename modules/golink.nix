{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with pkgs;
let
  inherit (inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}) golink;
  cfg = config.services.golink;
in
{
  options = with lib; {
    services.golink = {
      enable = mkEnableOption "Enable golink";

      user = mkOption {
        type =
          with types;
          oneOf [
            str
            int
          ];
        default = "golink";
        description = ''
          The user the service will use.
        '';
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/golink";
        description = ''
          Path to the golink sqlite database
        '';
      };

      envFile = mkOption {
        type = types.path;
        default = "/run/secrets/golink";
        description = ''
          Path to a file containing the golink tailscale auth token
        '';
      };

      group = mkOption {
        type =
          with types;
          oneOf [
            str
            int
          ];
        default = "golink";
        description = ''
          The user the service will use.
        '';
      };

      package = mkOption {
        type = types.package;
        default = golink;
        defaultText = literalExpression "pkgs.golink";
        description = "The package to use for golink";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      description = "golink service user";
      isSystemUser = true;
      home = cfg.dataDir;
      createHome = true;
      group = "${cfg.group}";
    };

    systemd.services.golink = {
      enable = true;
      description = "golink server";
      wants = [ "network-online.target" ];

      path = [ pkgs.vnstat ];

      environment = {
        HOME = cfg.dataDir;
        HOSTNAME = config.networking.hostName;
      };

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        RuntimeDirectory = "golink";
        StateDirectory = "golink";
        StateDirectoryMode = "0755";
        CacheDirectory = "golink";
        CacheDirectoryMode = "0755";

        EnvironmentFile = cfg.envFile;

        ExecStart = "${cfg.package}/bin/golink -sqlitedb ${cfg.dataDir}/golink.db";
      };
    };
  };
}
