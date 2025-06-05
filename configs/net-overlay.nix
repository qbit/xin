{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options = {
    zerotier = {
      enable = mkOption {
        description = "Enable ZeroTier";
        default = false;
        example = true;
        type = lib.types.bool;
      };
    };
    tailscale = {
      enable = mkOption {
        description = "Enable TailScale";
        default = true;
        example = true;
        type = lib.types.bool;
      };
      sshOnly = mkOption {
        description = "Enable TailScale with only ssh traffic to the tailnet allowed";
        default = false;
        example = true;
        type = lib.types.bool;
      };
    };
  };

  config = mkMerge [
    (mkIf config.tailscale.enable {
      services = {
        tailscale = {
          enable = mkDefault true;
          extraDaemonFlags = [
            "--no-logs-no-support"
          ];
        };
      };
      networking.firewall.checkReversePath = mkDefault "loose";
    })
    (mkIf (config.tailscale.enable && config.tailscale.sshOnly) {
      sops.secrets = {
        ts_sshonly = {
          sopsFile = config.xin-secrets.net-overlays;
          owner = "root";
          mode = "400";
        };
      };
      systemd.services = {
        "tailscale-ssh-init" = {
          wantedBy = [ "tailscaled.service" ];
          after = [ "tailscaled.service" ];
          serviceConfig = {
            ExecStart = "${pkgs.tailscale}/bin/tailscale up --auth-key file://${config.sops.secrets.ts_sshonly.path}";
          };
        };
      };
    })
    (mkIf config.zerotier.enable {
      environment.systemPackages = with pkgs; [ zerotierone ];
      services = {
        zerotierone = {
          enable = true;
          joinNetworks = [ "db64858fedd3b256" ];
        };
      };
      networking.firewall.checkReversePath = "loose";
    })
  ];
}
