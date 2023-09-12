{ config
, lib
, ...
}:
with lib; {
  options = {
    nixLockdown = {
      enable = mkOption {
        description = "Lockdown Nix";
        default = true;
        example = true;
        type = lib.types.bool;
      };
    };
  };
  config = mkIf config.nixLockdown.enable {
    nix = {
      settings = {
        sandbox = true;
        trusted-users = [ "@wheel" ];
        allowed-users = [ "root" "qbit" ];
      };
    };
  };
}
