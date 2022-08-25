{ config, lib, ... }:
with lib; {
  options = {
    doas = { enable = mkEnableOption "Enable doas for priv-escie"; };
  };

  config = mkIf config.doas.enable {
    nixpkgs.config.packageOverrides = pkgs: {
      doas = pkgs.doas.override { withPAM = false; };
    };
    security = {
      doas = {
        enable = true;
        extraRules = [{
          groups = [ "wheel" ];
          persist = true;
        }];

      };
      sudo.enable = false;
    };
  };
}
