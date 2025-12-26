{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options = {
    cosmic = {
      enable = mkEnableOption "Enable COSMIC desktop.";
    };
  };

  config = mkIf config.cosmic.enable {
    environment.systemPackages =
      let
        kdePkgs = with pkgs.kdePackages; [
          konversation
        ];
      in
      kdePkgs;

    services = {
      displayManager.cosmic-greeter.enable = true;
      desktopManager.cosmic = {
        enable = true;
        xwayland.enable = true;
      };
    };
  };
}
