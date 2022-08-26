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

  config = mkMerge [
    (mkIf config.autoUpdate.enable {
      system.autoUpgrade = {
        enable = true;
        allowReboot = false;
        flake = "github:qbit/xin";
        dates = "*-*-* *:03:00";
      };
    })
    {
      # Always add our host alias or we run into a bootstrap issue
      programs.ssh.extraConfig = ''
        Host xin-secrets-ro
          IdentityFile ${config.sops.secrets.xin_secrets_deploy_key.path}
          User gitea
          Port 2222
          Hostname git.tapenet.org
      '';
    }
  ];
}
