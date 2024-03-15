{ config
, lib
, isUnstable
, ...
}:
let
  inherit (lib) mkIf mkEnableOption mkMerge mkOption types;
in
{
  options = {
    kde = { enable = mkEnableOption "Enable KDE desktop."; };
    kdeConnect = {
      enable = mkEnableOption {
        description = "Enable PipeWire";
        default = false;
        example = true;
      };

      interface = mkOption {
        description = "listen interface for kde connect";
        default = "tailscale0";
        type = types.str;
      };
    };
  };

  config = mkIf config.kde.enable {
    services.xserver =
      mkMerge [
        (if isUnstable then {
          desktopManager.plasma6.enable = true;
          displayManager.sddm.wayland.enable = true;
        }
        else {
          desktopManager.plasma5.enable = true;
        })
        {
          displayManager.sddm.enable = true;
        }
      ];

    # Listen for KDE Connect connections on the tailnet
    networking.firewall.interfaces = mkIf config.kdeConnect.enable {
      "${config.kdeConnect.interface}" =
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
    programs.kdeconnect.enable = config.kdeConnect.enable;
  };
}
