{
  config,
  lib,
  ...
}:
with lib;
{
  options = {
    preDNS = {
      enable = mkOption {
        description = "Enable DNSSEC";
        default = true;
        example = true;
        type = lib.types.bool;
      };
    };
  };

  config = mkIf config.preDNS.enable {
    services = {
      openntpd.enable = true;
      dnscrypt-proxy2 = {
        enable = true;
        upstreamDefaults = false;
        settings = {
          server_names = [ "NextDNS-8436c6" ];
          static."NextDNS-8436c6".stamp = "sdns://AgEAAAAAAAAAAAAOZG5zLm5leHRkbnMuaW8HLzg0MzZjNg";
        };
      };
    };
  }; # tailscale and what not have no preDNS
}
