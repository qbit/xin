{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs;
let
  cfg = config.services.gotosocial;
  gotosocial = callPackage ../pkgs/gotosocial.nix { };
  settingsFormat = pkgs.formats.json { };
  settingsType = settingsFormat.type;
  prettyJSON =
    conf:
    pkgs.runCommandLocal "gotosocial-config.json" { } ''
      echo '${builtins.toJSON conf}' | ${pkgs.buildPackages.jq}/bin/jq 'del(._module)' > $out
    '';
in
{
  options = with lib; {
    services.gotosocial = {
      enable = mkEnableOption "Enable gotosocial";

      user = mkOption {
        type =
          with types;
          oneOf [
            str
            int
          ];
        default = "gotosocial";
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
        default = "gotosocial";
        description = ''
          The user the service will use.
        '';
      };

      configuration = mkOption {
        type = settingsType;
        description = ''
          Specify the configuration for GoToSocial in Nix.
        '';
      };

      package = mkOption {
        type = types.package;
        default = gotosocial;
        defaultText = literalExpression "pkgs.gotosocial";
        description = "The package to use for gotosocial";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.gotosocial = { };
    users.users.gotosocial = {
      description = "Gotosocial service user";
      isSystemUser = true;
      home = "/var/lib/gotosocial";
      createHome = true;
      group = "gotosocial";
    };

    systemd.services.gotosocial = {
      enable = true;
      description = "GoToSocial server";
      wantedBy = [ "multi-user.target" ];
      after = [ "postgresql.service" ];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        RuntimeDirectory = "/var/lib/gotosocial";

        ExecStart = "${cfg.package}/bin/gotosocial --config-path ${prettyJSON cfg.configuration} server start";
      };
    };
  };
}
