{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.hister;
in
{
  options = with lib; {
    services.hister = {
      enable = mkEnableOption {
        description = "Enable hister";
        default = false;
        example = true;
      };

      package = mkOption {
        type = types.package;
        default = pkgs.hister;
        defaultText = literalExpression "pkgs.hister";
        description = "Package to use for hister";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    systemd.user.services.hister = {
      enable = true;
      description = "hister daemon";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/hister listen";
        RestartSec = 3;
        TimeoutStopSec = 10;
      };
    };
  };
}
