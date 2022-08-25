{ config, lib, ... }:
with lib; {
  options = {
    autoUpdate = {
      enable = mkOption {
        description = "Enable Auto Update";
        default = true;
        example = true;
        type = lib.types.bool;
      };
    };
  };

  config = mkIf config.autoUpdate.enable {
    system.autoUpgrade = {
      enable = true;
      allowReboot = false;
    };
  };
}
