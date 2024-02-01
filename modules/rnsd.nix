{ lib
, config
, pkgs
, ...
}:
let
  cfg = config.services.rnsd;
  defaultSettings = { };
  settingsFormat = pkgs.formats.json { };
  settingsFile = settingsFormat.generate "rnsd-config.json" cfg.settings;
in
{
  options = with lib; {
    services.rnsd = {
      enable = lib.mkEnableOption "Enable rnsd";

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/rnsd";
        description = "Path rnsd home directory";
      };

      user = mkOption {
        type = with types; oneOf [ str int ];
        default = "rnsd";
        description = ''
          The user the service will use.
        '';
      };

      group = mkOption {
        type = with types; oneOf [ str int ];
        default = "rnsd";
        description = ''
          The group the service will use.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.python3Packages.rns;
        defaultText = literalExpression "pkgs.python3Packages.rns";
        description = "The package to use for rnsd";
      };

      settings = lib.mkOption {
        type = settingsFormat.type;
        default = defaultSettings;
        description = lib.mdDoc ''
          run `rnsd --exampleconfig` to see an example.
        '';
      };

      #port = lib.mkOption {
      #  type = types.int;
      #  defautl = 4242;
      #  defaultText = "4242";
      #  description = "Port to use for establishing an isolated net";
      #};

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "enable rnsd in the firewall";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ 4242 ];
      allowedUDPPorts = [ 4242 ];
    };

    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      description = "rnsd service user";
      isSystemUser = true;
      home = "${cfg.dataDir}";
      createHome = true;
      group = "${cfg.group}";
      extraGroups = [ "dialout" ];
    };
    systemd.services.rnsd = {
      enable = true;
      description = "rnsd server";
      wantedBy = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStartPre = "${pkgs.coreutils}/bin/ln -sf ${settingsFile} ${cfg.dataDir}/config";
        ExecStart = "${cfg.package}/bin/rnsd -s -v --config ${cfg.dataDir}";
      };
    };
  };
}
