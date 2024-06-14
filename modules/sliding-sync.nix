{ lib
, config
, pkgs
, ...
}:
let
  cfg = config.services.sliding-sync;
in
{
  options = with lib; {
    services.sliding-sync = {
      enable = lib.mkEnableOption "Enable sliding-sync";

      user = mkOption {
        type = with types; oneOf [ str int ];
        default = "syncv3";
        description = ''
          The user the service will use.
        '';
      };

      group = mkOption {
        type = with types; oneOf [ str int ];
        default = "syncv3";
        description = ''
          The group the service will use.
        '';
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/sliding-sync";
        description = "Path sliding-sync home directory";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.sliding-sync;
        defaultText = literalExpression "pkgs.sliding-sync";
        description = "The package to use for sliding-sync";
      };

      port = mkOption {
        type = types.int;
        default = 8098;
        description = "The port sliding-sync should listen on.";
      };

      address = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "The address sliding-sync should listen on.";
      };

      server = mkOption {
        type = types.str;
        default = "";
        description = "The matrix server to talk to.";
      };

      envFile = mkOption {
        type = types.path;
        default = "/run/secrets/sliding_sync_env";
        description = ''
          Path to a file containing the sliding-sync secret information.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      description = "sliding-sync service user";
      isSystemUser = true;
      home = "${cfg.dataDir}";
      createHome = true;
      group = "${cfg.group}";
    };

    systemd.services.sliding-sync = {
      enable = true;
      description = "sliding-sync server";
      wants = [ "network-online.target" "matrix-synapse.service" ];

      environment = {
        HOME = "${cfg.dataDir}";
        SYNCV3_BINDADDR = "${cfg.address}:${toString cfg.port}";
        SYNCV3_SERVER = cfg.server;
      };

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        ExecStart = "${cfg.package}/bin/syncv3";
        EnvironmentFile = cfg.envFile;
      };
    };
  };
}
