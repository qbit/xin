{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
in
with pkgs;
{
  options = {
    kde = {
      enable = mkEnableOption "Enable KDE desktop.";
    };
    kdeMobile = {
      enable = mkEnableOption "Enable KDE Mobile.";
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

  config = mkIf (config.kde.enable || config.kdeMobile.enable) {
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
      systemPackages =
        with kdePackages;
        [
          (pkgs.callPackage ../pkgs/krunner-krha.nix { })
          evolutionWithPlugins
          evolution-ews
          akonadi-calendar-tools
          discover
          haruna
          kcalc
          kcolorchooser
          kdeconnect-kde
          kcontacts
          kmail
          kmail-account-wizard
          kolourpaint
          kontact
          konversation
          korganizer
          kzones
          merkuro
          partitionmanager
          sddm-kcm
          wayland-utils
          wl-clipboard
        ]
        ++ (if config.kdeMobile.enable then [ plasma-mobile ] else [ ]);
    };
  };
}
