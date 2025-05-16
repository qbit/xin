{ config
, lib
, ...
}:
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
    needsDeploy = {
      enable = mkOption {
        description = "Host needs deploy key to receive encrypted secrets";
        default = true;
        example = true;
        type = lib.types.bool;
      };
    };
  };

  config = mkMerge [
    (mkIf config.autoUpdate.enable {
      system.autoUpgrade = {
        # enable is set in lib/default.nix depending on the state of the tree
        # DIRTY means disabled, git revision means enabled
        allowReboot = mkDefault true;
        flake = "git+https://codeberg.org/qbit/xin";
        dates = "*-*-* *:05:00";
      };
    })

    # Always add our host alias or we run into a bootstrap issue
    (mkIf config.needsDeploy.enable {
      programs.ssh.extraConfig =
        ''
          Host xin-secrets-ro
            IdentityFile ${config.sops.secrets.xin_secrets_deploy_key.path}
            User gitea
            Port 2222
            Hostname git.tapenet.org
        '';
    })
  ];
}
