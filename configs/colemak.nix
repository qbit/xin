{ config, lib, ... }:
with lib; {
  options = {
    colemak = {
      enable = mkOption {
        description = "Enable colemak keyboard layout";
        default = true;
        example = true;
        type = lib.types.bool;
      };
    };
  };

  config = mkIf config.colemak.enable {
    console = { keyMap = "colemak"; };
    services.xserver = {
      layout = "us";
      xkbVariant = "colemak";
      xkbOptions = "ctrl:swapcaps";
    };
  };
}
