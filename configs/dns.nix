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
    networking = {
      nameservers = [
        "127.0.0.1"
        "::1"
      ];

      networkmanager.dns = "none";
      dhcpcd.extraConfig = "nohook resolv.conf";
    };

    services = {
      openntpd.enable = true;
      dnscrypt-proxy = {
        enable = true;
        upstreamDefaults = false;
        settings = {
          server_names = [ "NextDNS-8436c6" ];
          static."NextDNS-8436c6".stamp = "sdns://AgEAAAAAAAAAAAAOZG5zLm5leHRkbnMuaW8HLzg0MzZjNg";
        };
      };
      resolved.enable = false;
      avahi = {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = true;
      };
    };
  }; # tailscale and what not have no preDNS
}
