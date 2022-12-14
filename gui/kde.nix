{ config, lib, pkgs, ... }:
let inherit (pkgs.libsForQt5) callPackage;
in {
  options = { kde = { enable = lib.mkEnableOption "Enable KDE desktop."; }; };

  config = lib.mkIf config.kde.enable {
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    # Listen for KDE Connect connections on the tailnet
    networking.firewall.interfaces = {
      "tailscale0" = {
        allowedTCPPorts = lib.range 1714 1764;
        allowedUDPPorts = lib.range 1714 1764;
      };
    };

    environment.systemPackages = with pkgs; [
      (callPackage ../pkgs/rkvm.nix { })
      (callPackage ../pkgs/tile-gaps.nix { })
      libsForQt5.bismuth
      plasma5Packages.kdeconnect-kde
      waynergy
    ];
  };
}
