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

  config =
    let
      hasQbit =
        if builtins.hasAttr "qbit" config.xin-secrets.${config.networking.hostName}.user_passwords then
          true
        else false;
    in
    mkIf config.defaultUsers.enable {
      sops =
        {
          age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
          secrets = mkMerge [
            ({
              root_hash =
                {
                  sopsFile = config.xin-secrets.${config.networking.hostName}.user_passwords.root;
                  owner = "root";
                  mode = "400";
                  neededForUsers = true;
                };
            })
            (mkIf hasQbit {
              qbit_hash = {
                sopsFile = config.xin-secrets.${config.networking.hostName}.user_passwords.qbit;
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
          (
            {
              root = userBase // {
                hashedPasswordFile = config.sops.secrets.root_hash.path;
              };
            })
          (mkIf hasQbit {
            qbit = userBase // {
              isNormalUser = true;
              description = "Aaron Bieber";
              home = "/home/qbit";
              extraGroups = [ "wheel" ];
              hashedPasswordFile = config.sops.secrets.qbit_hash.path;
            };
          })
        ];
      };
    };
}
