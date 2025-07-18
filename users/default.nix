{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  userBase = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = config.myconf.hwPubKeys ++ config.myconf.managementPubKeys;
  };
  cfg = config;
in
{
  options = {
    defaultUserName = mkOption {
      description = "Default user for a system";
      default = "qbit";
      example = "qbit";
      type = lib.types.str;
    };
    defaultUsers = {
      enable = mkOption {
        description = "Enable regular set of users";
        default =
          if (builtins.hasAttr "${config.networking.hostName}" config.xin-secrets) then true else false;
        example = true;
        type = lib.types.bool;
      };
    };
  };

  config =
    let
      inherit (config.networking) hostName;
      hasDefault =
        if
          (builtins.hasAttr hostName config.xin-secrets)
          && (builtins.hasAttr cfg.defaultUserName config.xin-secrets.${hostName}.user_passwords)
        then
          true
        else
          false;
    in
    mkIf config.defaultUsers.enable {
      sops =
        let
          secretAttrs = config.xin-secrets.${hostName}.user_passwords;
        in
        {
          age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
          secrets = mkMerge [
            {
              root_hash = {
                name = "hash";
                sopsFile = secretAttrs.root;
                owner = "root";
                mode = "400";
                neededForUsers = true;
              };
            }
            (mkIf hasDefault {
              "${cfg.defaultUserName}_hash" = {
                sopsFile = secretAttrs."${cfg.defaultUserName}";
                owner = "root";
                mode = "400";
                neededForUsers = true;
              };
            })
          ];
        };
      users = {
        mutableUsers = false;
        users = mkMerge [
          {
            root = userBase // {
              hashedPasswordFile = config.sops.secrets.root_hash.path;
            };
          }
          (mkIf hasDefault {
            "${cfg.defaultUserName}" = userBase // {
              isNormalUser = true;
              description = "Aaron Bieber";
              home = "/home/${cfg.defaultUserName}";
              extraGroups = [ "wheel" ];
              hashedPasswordFile = config.sops.secrets."${cfg.defaultUserName}_hash".path;
            };
          })
        ];
      };
    };
}
