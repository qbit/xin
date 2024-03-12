{ config
, lib
, pkgs
, isUnstable
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

  config = mkIf config.defaultUsers.enable {
    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      secrets = {
        "${config.networking.hostName}_hash" = {
          sopsFile = config.xin-secrets.root_passwords;
          owner = "root";
          mode = "400";
          neededForUsers = true;
        };
        qbit_hash = {
          sopsFile = config.xin-secrets.user_passwords;
          owner = "root";
          mode = "400";
          neededForUsers = true;
        };
      };
    };
    users = {
      mutableUsers = false;
      users = {
        root = userBase // {
          hashedPasswordFile = config.sops.secrets."${config.networking.hostName}_hash".path;
        };
        qbit = userBase // {
          isNormalUser = true;
          description = "Aaron Bieber";
          home = "/home/qbit";
          extraGroups = [ "wheel" ];
          hashedPasswordFile = config.sops.secrets.qbit_hash.path;
        };
      };
    };

    environment.systemPackages =
      if isUnstable
      then [ pkgs.yash pkgs.go ]
      else [ pkgs.go ];
  };
}
