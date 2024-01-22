{ lib
, config
, pkgs
, ...
}:
let
  cfg = config.services.nomadnet;
  defaultSettings = { };
  settingsFormat = pkgs.formats.toml { };
  settingsFile = settingsFormat.generate "config.toml" cfg.settings;
in
{
  options = with lib; {
    services.nomadnet = {
      enable = lib.mkEnableOption "Enable nomadnet";

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/nomadnet";
        description = "Path nomadnet home directory";
      };

      user = mkOption {
        type = with types; oneOf [ str int ];
        default = "nomadnet";
        description = ''
          The user the service will use.
        '';
      };

      group = mkOption {
        type = with types; oneOf [ str int ];
        default = "nomadnet";
        description = ''
          The group the service will use.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.python3Packages.nomadnet;
        defaultText = literalExpression "pkgs.python3Packages.nomadnet";
        description = "The package to use for nomadnet";
      };

      settings = lib.mkOption {
        type = settingsFormat.type;
        default = defaultSettings;
        description = lib.mdDoc ''
          run `nomadnet --exampleconfig` to see an example.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      description = "nomadnet service user";
      isSystemUser = true;
      home = "${cfg.dataDir}";
      createHome = true;
      group = "${cfg.group}";
    };
    systemd.services.nomadnet = {
      enable = true;
      description = "nomadnet server";
      wantedBy = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        #DynamicUser = true;
        #User = "nomadnet";
        #Group = "nomadnet";
        #StateDirectory = "nomadnet";
        #CacheDirectory = "nomadnet";
        #LogsDirectory = "nomadnet";
        #ProtectHome = true;
        ExecStartPre = "${pkgs.coreutils}/bin/ln -sf ${settingsFile} ${cfg.dataDir}/config";
        ExecStart = "${cfg.package}/bin/nomadnet -d --config ${cfg.dataDir}";
      };
    };
  };
}
