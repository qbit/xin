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
      resolved = {
        enable = true;
        dnssec = "allow-downgrade";
        # TODO: Enable a toggle for ipv6
        fallbackDns = [
          "9.9.9.9"
          "2620:fe::fe"
          "149.112.112.112"
          "2620:fe::9"
        ];
        extraConfig = ''
          [Resolve]
            DNS=45.90.28.0#8436c6.dns.nextdns.io
            DNS=2a07:a8c0::#8436c6.dns.nextdns.io
            DNS=45.90.30.0#8436c6.dns.nextdns.io
            DNS=2a07:a8c1::#8436c6.dns.nextdns.io
            DNSOverTLS=yes
        '';
      };
    };
  }; # tailscale and what not have no preDNS
}
