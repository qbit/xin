{
  config,
  lib,
  pkgs,
  isUnstable,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  kconnect = mkIf config.kdeConnect.enable (
    if isUnstable then pkgs.kdePackages.kdeconnect-kde else pkgs.plasma5Packages.kdeconnect-kde
  );
in
with pkgs;
{
  options = {
    kde = {
      enable = mkEnableOption "Enable KDE desktop.";
    };
    kdeConnect = {
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
    };
  };

  config = mkIf config.kde.enable {
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
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
    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = 1;
      };
      systemPackages = with kdePackages; [
        akonadi-calendar-tools
        kcolorchooser
        kconnect
        kontact
        kcontacts
        konversation
        korganizer
        kzones
        merkuro
        (pkgs.callPackage ../pkgs/krunner-krha.nix { })
        wl-clipboard
      ];
    };
  };
}
