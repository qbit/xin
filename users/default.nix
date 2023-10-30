{ config
, lib
, pkgs
, ...
}:
with lib; let
  userBase = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys =
      config.myconf.hwPubKeys
      ++ config.myconf.managementPubKeys;
  };
in
{
  options = {
    defaultUsers = {
      enable = mkOption {
        description = "Enable regular set of users";
        default = true;
        example = true;
        type = lib.types.bool;
      };
    };
  };

  config = mkIf config.defaultUsers.enable
    {
      users.users = {
        root = userBase;
        qbit = userBase // {
          isNormalUser = true;
          description = "Aaron Bieber";
          home = "/home/qbit";
          extraGroups = [ "wheel" ];
        };
      };
    };
}
