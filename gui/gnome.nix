{ config, lib, ... }:
with lib; {
  options = { gnome = { enable = mkEnableOption "Enable GNOME desktop."; }; };

  config = mkIf config.gnome.enable {
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
  };
}
