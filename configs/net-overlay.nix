{ config, lib, pkgs, ... }:
with lib; {
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
    };
  };

  config = mkMerge [
    (mkIf config.tailscale.enable {
      services = { tailscale = { enable = true; }; };
      networking.firewall.checkReversePath = "loose";
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
