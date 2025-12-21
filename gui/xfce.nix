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
      sddm = {
        kwallet = {
          enable = true;
          forceRun = true;
        };
      };
      kwallet = {
        name = "kwallet";
        enableKwallet = true;
      };
    };

    environment.systemPackages =
      let
        kdePkgs = with pkgs.kdePackages; [
          konversation
          kwallet
          kwallet-pam
          kwalletmanager
        ];
      in
      with pkgs;
      [
        supersonic
      ]
      ++ kdePkgs;

    services = {
      displayManager.sddm.enable = true;
      xserver.desktopManager.xfce = {
        enable = true;
      };
    };
  };
}
