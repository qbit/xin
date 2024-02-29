{ config
, lib
, isUnstable
, ...
}:
{
  options = { kde = { enable = lib.mkEnableOption "Enable KDE desktop."; }; };

  config = lib.mkIf config.kde.enable {
    services.xserver =
      if isUnstable then {
        desktopManager.plasma6.enable = true;
      }
      else {
        desktopManager.plasma5.enable = true;
      } // {
        displayManager.sddm.enable = true;
      };

    # Listen for KDE Connect connections on the tailnet
    networking.firewall.interfaces = {
      "tailscale0" = {
        allowedTCPPorts = lib.range 1714 1764;
        allowedUDPPorts = lib.range 1714 1764;
      };
    };

    programs.kdeconnect.enable = true;
  };
}
