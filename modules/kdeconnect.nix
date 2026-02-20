{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.kdeconnect;
in
{
  options = with lib; {
    kdeconnect = {
      enable = mkEnableOption {
        description = "Enable KDE Connect";
        default = false;
        example = true;
      };

      interface = mkOption {
        description = "listen interface for kde connect";
        default = "tailscale0";
        type = types.str;
      };

      package = mkOption {
        type = types.package;
        default = pkgs.kdePackages.kdeconnect-kde;
        defaultText = literalExpression "pkgs.kdePackages.kdeconnect";
        description = "Package to use for kdeconnect";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.interfaces = {
      "${config.kdeconnect.interface}" =
        let
          range = {
            from = 1714;
            to = 1764;
          };
        in
        {
          allowedUDPPortRanges = [ range ];
          allowedTCPPortRanges = [ range ];
        };
    };

    environment.systemPackages = with pkgs; [
      kdePackages.kdeconnect-kde
    ];

    systemd.user.services.kdeconnectd = {
      enable = true;
      description = "kdeconnect daemon";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/kdeconnectd";
        RestartSec = 3;
        TimeoutStopSec = 10;
      };
    };
  };
}
