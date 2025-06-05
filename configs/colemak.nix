{
  config,
  lib,
  ...
}:
with lib;
{
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
    console = {
      keyMap = "colemak";
    };
    services.xserver = {
      xkb = {
        options = "ctrl:swapcaps,compose:ralt";
        variant = "colemak";
        layout = "us";
      };
      inputClassSections = [
        ''
          Identifier "precursor"
          MatchIsKeyboard "on"
          MatchProduct "Precursor"
          MatchVendor "Kosagi"
          Option "XkbLayout" "us"
          Option "XkbVariant" "basic"
        ''
        ''
          Identifier "atreus"
          MatchIsKeyboard "on"
          MatchProduct "Keyboardio Atreus"
          MatchVendor "Keyboardio"
          Option "XkbLayout" "us"
          Option "XkbVariant" "basic"
        ''
      ];
    };
  };
}
