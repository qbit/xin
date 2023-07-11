{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.tsrevprox;
in {
  options = with lib; {
    services.tsrevprox = {
      enable = lib.mkEnableOption "Enable tsrevprox";

      reversePort = mkOption {
        type = types.int;
        default = 5000;
        description = ''
          Port to forward connections to.
        '';
      };

      reverseIP = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = ''
          IP to forward connections to.
        '';
      };

      reverseName = mkOption {
        type = types.str;
        default = "tsrevprox";
        description = ''
          Name used in for the front facing http server (will be a tailscale name).
        '';
      };

      user = mkOption {
        type = with types; oneOf [str int];
        default = "tsrevprox";
        description = ''
          The user the service will use.
        '';
      };

      group = mkOption {
        type = with types; oneOf [str int];
        default = "tsrevprox";
        description = ''
          The group the service will use.
        '';
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/tsrevprox";
        description = "Path tsrevprox home directory";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.ts-reverse-proxy;
        defaultText = literalExpression "pkgs.ts-reverse-proxy";
        description = "The package to use for ts-reverse-proxy";
      };

      envFile = mkOption {
        type = types.path;
        default = "/run/secrets/ts_proxy_env";
        description = ''
          Path to a file containing the ts-reverse-proxy token information
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = {};
    users.users.${cfg.user} = {
      description = "tsrevprox service user";
      isSystemUser = true;
      home = "${cfg.dataDir}";
      createHome = true;
      group = "${cfg.group}";
    };

    systemd.services.tsrevprox = {
      enable = true;
      description = "tsrevprox server";
      wantedBy = ["network-online.target"];
      after = ["network-online.target"];

      environment = {HOME = "${cfg.dataDir}";};

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        ExecStart = "${cfg.package}/bin/ts-reverse-proxy -name ${cfg.reverseName} -port ${
          toString cfg.reversePort
        } -ip ${cfg.reverseIP}";
        EnvironmentFile = cfg.envFile;
      };
    };
  };
}
