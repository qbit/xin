{ config
, lib
, pkgs
, ...
}:
with lib; {
  options = {
    arcan = { enable = mkEnableOption "Enable Arcan/Durden desktop."; };
  };

  config = mkIf config.arcan.enable {
    environment.systemPackages = with pkgs; [ arcanPackages.all-wrapped ];
  };
}
