{ config, lib, isUnstable, ... }:
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
    nix = if isUnstable then {
      settings.sandbox = true;
      settings.trusted-users = [ "@wheel" ];
      settings.allowed-users = [ "root" "qbit" ];
    } else {
      allowedUsers = [ "@wheel" ];
      trustedUsers = [ "root" "qbit" ];
      useSandbox = true;
    };

  };
}
