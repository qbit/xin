{ config
, lib
, pkgs
, ...
}:
let cfg = config.services.signal-cli;
in
with pkgs; {
  options = with lib; {
    services.signal-cli = {
      enable = mkEnableOption "Enable signal-cli";

      user = mkOption {
        type = with types; oneOf [ str int ];
        default = "signal-cli";
        description = ''
          The user the service will use.
        '';
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/signal-cli";
        description = ''
          Path to the signal-cli sqlite database
        '';
      };

      socketPath = mkOption {
        type = types.path;
        default = "${cfg.dataDir}/socket";
        description = "Path to create the socket on";
      };

      envFile = mkOption {
        type = types.path;
        default = "/run/secrets/signal-cli";
        description = ''
          Path to a file containing the signal-cli tailscale auth token
        '';
      };

      group = mkOption {
        type = with types; oneOf [ str int ];
        default = "signal-cli";
        description = ''
          The user the service will use.
        '';
      };

      package = mkOption {
        type = types.package;
        default = signal-cli;
        defaultText = literalExpression "pkgs.signal-cli";
        description = "The package to use for signal-cli";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      description = "signal-cli service user";
      isSystemUser = true;
      home = cfg.dataDir;
      homeMode = "0750";
      createHome = true;
      group = "${cfg.group}";
    };

    systemd.services.signal-cli = {
      enable = true;
      description = "signal-cli server";
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        HOME = cfg.dataDir;
      };

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        RuntimeDirectory = "signal-cli";
        StateDirectory = "signal-cli";
        StateDirectoryMode = "0750";
        CacheDirectory = "signal-cli";
        CacheDirectoryMode = "0700";

        EnvironmentFile = cfg.envFile;

        ExecStart = "${cfg.package}/bin/signal-cli --scrub-log -a $SIGNAL_NUMBER daemon --socket ${cfg.socketPath}";
      };
    };
  };
}
