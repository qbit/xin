{ config, lib, ... }:
with lib; {
  options = { xfce = { enable = mkEnableOption "Enable XFCE desktop."; }; };

  config = mkIf config.xfce.enable {
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.xfce = { enable = true; };
  };
}
