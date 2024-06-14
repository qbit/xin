{ config
, lib
, pkgs
, inputs
, ...
}:
with pkgs; let
  cfg = config.services.tsvnstat;
  inherit (inputs.tsvnstat.packages.${pkgs.system}) tsvnstat;
in
{
  options = with lib; {
    services.tsvnstat = {
      enable = mkEnableOption "Enable tsvnstat";

      user = mkOption {
        type = with types; oneOf [ str int ];
        default = "tsvnstat";
        description = ''
          The user the service will use.
        '';
      };

      keyPath = mkOption {
        type = with types; oneOf [ path str ];
        default = "";
        description = ''
          Path to the TS API key file
        '';
      };

      nodeName = mkOption {
        type = types.str;
        default = "${config.networking.hostName}-stats";
        description = ''
          The name of the TS node.
        '';
      };

      group = mkOption {
        type = with types; oneOf [ str int ];
        default = "tsvnstat";
        description = ''
          The user the service will use.
        '';
      };
      package = mkOption {
        type = types.package;
        default = tsvnstat;
        defaultText = literalExpression "pkgs.tsvnstat";
        description = "The package to use for tsvnstat";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      description = "tsvnstat service user";
      isSystemUser = true;
      home = "/var/lib/tsvnstat";
      createHome = true;
      group = "${cfg.group}";
    };

    services.vnstat.enable = true;

    systemd.services.tsvnstat = {
      enable = true;
      description = "tsvnstat server";
      wants = [ "network-online.target" ];

      path = [ pkgs.vnstat ];

      environment = {
        HOME = "/var/lib/tsvnstat";
        HOSTNAME = config.networking.hostName;
      };

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        RuntimeDirectory = "tsvnstat";
        StateDirectory = "tsvnstat";
        StateDirectoryMode = "0755";
        CacheDirectory = "tsvnstat";
        CacheDirectoryMode = "0755";

        ExecStart = ''
          ${cfg.package}/bin/tsvnstat -vnstati ${pkgs.vnstat}/bin/vnstati -name ${cfg.nodeName} ${lib.optionalString (cfg.keyPath != "") "-key ${cfg.keyPath}"}
        '';
      };
    };
  };
}
