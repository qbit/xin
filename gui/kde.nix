{ config, lib, pkgs, ... }:
with lib; {
  options = { kde = { enable = mkEnableOption "Enable KDE desktop."; }; };

  config = mkIf config.kde.enable {
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    # Listen for KDE Connect connections on the tailnet
    networking.firewall.interfaces = {
      "tailscale0" = {
        allowedTCPPorts = range 1714 1764;
        allowedUDPPorts = range 1714 1764;
      };
    };

    environment.systemPackages = with pkgs; [
      akonadi
      plasma5Packages.akonadiconsole
      plasma5Packages.akonadi-contacts
      plasma5Packages.akonadi-search
      plasma5Packages.akonadi-mime
      libsForQt5.bismuth
      kdeconnect
      plasma-pass
    ];
  };
}
