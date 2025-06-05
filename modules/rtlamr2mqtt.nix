{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs;
let
  cfg = config.services.rtlamr2mqtt;
  rtlamr2mqtt = pkgs.python3Packages.callPackage ../pkgs/rtlamr2mqtt.nix { };
  settingsFormat = pkgs.formats.json { };
  settingsType = settingsFormat.type;
  prettyJSON =
    conf:
    pkgs.runCommandLocal "rtlamr2mqtt-config.json" { } ''
      echo '${builtins.toJSON conf}' | ${pkgs.buildPackages.jq}/bin/jq 'del(._module)' > $out
    '';
in
{
  options = with lib; {
    services.rtlamr2mqtt = {
      enable = mkEnableOption "Enable rtlamr2mqtt";

      user = mkOption {
        type =
          with types;
          oneOf [
            str
            int
          ];
        default = "rtlamr2mqtt";
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
        default = "rtlamr2mqtt";
        description = ''
          The user the service will use.
        '';
      };

      configuration = mkOption {
        type = settingsType;
        description = ''
          Specify the configuration for rtlamr2mqtt in Nix.
        '';
      };

      package = mkOption {
        type = types.package;
        default = rtlamr2mqtt;
        defaultText = literalExpression "pkgs.rtlamr2mqtt";
        description = "The package to use for rtlamr2mqtt";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.rtlamr2mqtt = { };
    users.users.rtlamr2mqtt = {
      description = "rtlamr2mqtt service user";
      isSystemUser = true;
      home = "/var/lib/rtlamr2mqtt";
      createHome = true;
      group = "rtlamr2mqtt";
      extraGroups = [ "plugdev" ];
    };

    systemd.services.rtlamr2mqtt = {
      enable = true;
      description = "rtlamr2mqtt server";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        RuntimeDirectory = "rtlamr2mqtt";

        ExecStart = "${cfg.package}/bin/rtlamr2mqtt ${prettyJSON cfg.configuration}";
      };
    };
  };
}
