{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs;
let
  cfg = config.services.yarr;
  yarr = callPackage ../pkgs/yarr.nix { };
in
{
  options = with lib; {
    services.yarr = {
      enable = mkEnableOption "Enable yarr";

      directory = mkOption {
        type = types.str;
        default = "/var/lib/yarr";
        description = "Persistent directory to house database.";
      };

      basePath = mkOption {
        type = types.str;
        default = "";
        description = "Base path of the service URL.";
      };

      authFilePath = mkOption {
        type = types.str;
        default = "/run/secrets/yarr_auth";
        description = "Path to file containing authentication information.";
      };

      address = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = ''
          Address to run yarr on.
        '';
      };

      port = mkOption {
        type = types.int;
        default = 7070;
        description = "Port to listen on";
      };

      dbPath = mkOption {
        type = types.str;
        default = "${cfg.directory}/storage.db";
        description = "Full path to the database file.";
      };

      user = mkOption {
        type =
          with types;
          oneOf [
            str
            int
          ];
        default = "yarr";
        description = ''
          The user the service will use.
        '';
      };

      group = mkOption {
        type =
          with types;
          oneOf [
            str
            int
          ];
        default = "yarr";
        description = ''
          The user the service will use.
        '';
      };

      package = mkOption {
        type = types.package;
        default = yarr;
        defaultText = literalExpression "pkgs.yarr";
        description = "The package to use for yarr";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.yarr = { };
    users.users.yarr = {
      description = "Yarr service user";
      isSystemUser = true;
      home = "${cfg.directory}";
      createHome = true;
      group = "yarr";
    };

    systemd.services.yarr = {
      enable = true;
      description = "Yet Another Rss Reader server";
      wantedBy = [ "multi-user.target" ];
      after = [ "networking.service" ];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        ExecStart = "${cfg.package}/bin/yarr -addr ${cfg.address}:${toString cfg.port} -db ${cfg.dbPath} -auth-file ${cfg.authFilePath}";
      };
    };
  };
}
