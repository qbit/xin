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
    security.pam.services = {
      gdm.enableKwallet = true;
      kdm.enableKwallet = true;
      lightdm.enableKwallet = true;
      sddm.enableKwallet = true;
      slim.enableKwallet = true;
    };

    environment.systemPackages = with pkgs.libsForQt5; [
      kwallet
      kwallet-pam
      kwalletmanager
    ];

    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.xfce = {
      enable = true;
    };
  };
}
