{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options = {
    xfce = {
      enable = mkEnableOption "Enable XFCE desktop.";
    };
  };

  config = mkIf config.xfce.enable {
    environment.systemPackages =
      let
        kdePkgs = with pkgs.kdePackages; [
          konversation
        ];
      in
      kdePkgs;

    services = {
      displayManager.sddm.enable = true;
      xserver.desktopManager.xfce = {
        enable = true;
      };
    };
  };
}
