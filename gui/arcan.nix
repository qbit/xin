{ config, lib, pkgs, ... }:
let myArcan = pkgs.arcanPackages or pkgs.arcan;
in with lib; {
  options = {
    arcan = { enable = mkEnableOption "Enable Arcan/Durden desktop."; };
  };

  config = mkIf config.arcan.enable {
    environment.systemPackages = with pkgs; [ myArcan.all-wrapped ];
  };
}
