{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (builtins)
    head
    concatStringsSep
    attrValues
    mapAttrs
    attrNames
    ; # hasAttr;
  inherit (lib.attrsets) filterAttrsRecursive filterAttrs;
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];
  userBase = {
    openssh.authorizedKeys.keys = pubKeys ++ config.myconf.managementPubKeys;
  };

  wan = "enp5s0f0";
  trunk = "enp5s0f1";
  dnsServers = [
    "45.90.28.147"
    "45.90.30.147"
  ];
  interfaces = {
    "${wan}" = {
      useDHCP = true;
    };
    "${trunk}" = rec {
      ipv4.addresses = [
        {
          address = "10.99.99.1";
          prefixLength = 24;
        }
      ];
      info = rec {
        description = "Management";
        route = false;
        router = "${(head ipv4.addresses).address}";
        netmask = "255.255.255.0";
        network = "${net}/${toString (head ipv4.addresses).prefixLength}";
        net = "10.99.99.0";
        dhcp = {
          enable = true;
          start = "10.99.99.100";
          end = "10.99.99.150";
          staticIPs = [
            {
              name = "doublemint";
              mac = "74:83:c2:19:9e:51";
              address = "10.99.99.54";
            }
            {
              name = "switch0";
              mac = "18:e8:29:b5:48:15";
              address = "10.99.99.4";
            }
            {
              name = "switch1";
              mac = "fc:ec:da:4e:2e:51";
              address = "10.99.99.5";
            }
            {
              name = "switch2";
              mac = "fc:ec:da:d4:10:81";
              address = "10.99.99.6";
            }
            {
              name = "ap2";
              mac = "74:83:c2:89:0b:52";
              address = "10.99.99.7";
            }
            {
              name = "ap1";
              mac = "80:2a:a8:96:50:76";
              address = "10.99.99.8";
            }
          ];
        };
      };
    };
    enp1s0f0 = rec {
      ipv4.addresses = [
        {
          address = "10.99.1.1";
          prefixLength = 24;
        }
      ];
      info = rec {
        description = "unused";
        route = true;
        router = "${(head ipv4.addresses).address}";
        net = "10.99.1.0";
        netmask = "255.255.255.0";
        network = "${net}/${toString (head ipv4.addresses).prefixLength}";
        dhcp = {
          enable = true;
          start = "10.99.1.100";
          end = "10.99.1.155";
          staticIPs = [ ];
        };
      };
    };
    enp2s0f1 = rec {
      ipv4.addresses = [
        {
          address = "10.98.1.1";
          prefixLength = 24;
        }
      ];
      info = rec {
        description = "work";
        route = false;
        router = "${(head ipv4.addresses).address}";
        net = "10.98.1.0";
        netmask = "255.255.255.0";
        network = "${net}/${toString (head ipv4.addresses).prefixLength}";
        dhcp = {
          enable = true;
          start = "10.98.1.100";
          end = "10.98.1.150";
          staticIPs = [ ];
        };
      };
    };
    badwifi = rec {
      ipv4.addresses = [
        {
          address = "10.10.0.1";
          prefixLength = 24;
        }
      ];
      info = rec {
        description = "IoT WiFi";
        route = true;
        router = "${(head ipv4.addresses).address}";
        net = "10.10.0.0";
        netmask = "255.255.255.0";
        network = "${net}/${toString (head ipv4.addresses).prefixLength}";
        dhcp = {
          enable = true;
          start = "10.10.0.100";
          end = "10.10.0.155";
          staticIPs = [ ];
        };
      };
    };
    goodwifi = rec {
      ipv4.addresses = [
        {
          address = "10.12.0.1";
          prefixLength = 24;
        }
      ];
      info = rec {
        description = "WiFi";
        route = false;
        router = "${(head ipv4.addresses).address}";
        net = "10.12.0.0";
        netmask = "255.255.255.0";
        network = "${net}/${toString (head ipv4.addresses).prefixLength}";
        dhcp = {
          enable = false;
          start = "10.12.0.100";
          end = "10.12.0.155";
          staticIPs = [ ];
        };
      };
    };
    lab = rec {
      ipv4.addresses = [
        {
          address = "10.3.0.1";
          prefixLength = 24;
        }
      ];
      info = rec {
        vlanID = 2;
        description = "Lab";
        route = true;
        router = "${(head ipv4.addresses).address}";
        net = "10.3.0.0";
        netmask = "255.255.255.0";
        network = "${net}/${toString (head ipv4.addresses).prefixLength}";
        dhcp = {
          enable = true;
          start = "10.3.0.100";
          end = "10.3.0.155";
          staticIPs = [
            {
              name = "bbb";
              mac = "c8:a0:30:ac:1d:0d";
              address = "10.3.0.2";
            }
          ];
        };
      };
    };
    external = rec {
      ipv4.addresses = [
        {
          address = "10.20.30.1";
          prefixLength = 24;
        }
      ];
      info = rec {
        description = "DMZ";
        route = true;
        router = "${(head ipv4.addresses).address}";
        net = "10.20.30.0";
        netmask = "255.255.255.0";
        network = "${net}/${toString (head ipv4.addresses).prefixLength}";
        dhcp = {
          enable = false;
          start = "10.20.30.100";
          end = "10.20.30.155";
          staticIPs = [ ];
        };
      };
    };
    common = rec {
      ipv4.addresses = [
        {
          address = "10.6.0.1";
          prefixLength = 24;
        }
      ];
      info = rec {
        description = "Common";
        route = true;
        router = "${(head ipv4.addresses).address}";
        vlanID = 5;
        net = "10.6.0.0";
        netmask = "255.255.255.0";
        network = "${net}/${toString (head ipv4.addresses).prefixLength}";
        dhcp = {
          enable = true;
          start = "10.6.0.100";
          end = "10.6.0.250";
          staticIPs = [
            {
              name = "tal";
              mac = "3c:7c:3f:1d:95:9c";
              address = "10.6.0.110";
            }
            {
              name = "namish";
              mac = "b8:ae:ed:78:b5:37";
              address = "10.6.0.78";
            }
            {
              name = "g5";
              mac = "00:0a:95:a8:26:42";
              address = "10.6.0.111";
            }
            {
              name = "box";
              mac = "d0:50:99:c2:b5:4b";
              address = "10.6.0.15";
            }
            {
              name = "greenhouse";
              mac = "6c:0b:84:1b:20:07";
              address = "10.6.0.20";
            }
            {
              name = "inside";
              mac = "6c:0b:84:cb:a7:59";
              address = "10.6.0.21";
            }
            {
              name = "weather";
              mac = "b8:27:eb:3e:5b:4e";
              address = "10.6.0.22";
            }
          ];
        };
      };
    };
    voip = rec {
      ipv4.addresses = [
        {
          address = "10.7.0.1";
          prefixLength = 24;
        }
      ];
      info = rec {
        description = "VoIP";
        route = true;
        router = "${(head ipv4.addresses).address}";
        net = "10.7.0.0";
        netmask = "255.255.255.0";
        network = "${net}/${toString (head ipv4.addresses).prefixLength}";
        dhcp = {
          enable = false;
          start = "10.7.0.100";
          end = "10.7.0.155";
          staticIPs = [ ];
        };
      };
    };
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/tsvnstat.nix
  ];

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;

    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;

    "net.netfilter.nf_conntrack_helper" = true;
  };

  sops.secrets = {
    wireguard_private_key = {
      sopsFile = config.xin-secrets.router.networking;
    };
    router_stats_ts_key = {
      sopsFile = config.xin-secrets.router.networking;
      owner = config.users.users.tsvnstat.name;
    };
  };

  networking = {
    hostName = "router";

    enableIPv6 = true;
    useDHCP = false;
    firewall.enable = false;
    dhcpcd = {
      enable = true;
      extraConfig = ''
        interface ${wan}
        ipv6rs
        iaid 1
        ia_pd 1 common
      '';
    };

    # TODO: iterate over interfaces where .<name>.vlanID is set
    vlans = {
      badwifi = {
        id = 10;
        interface = "${trunk}";
      };
      goodwifi = {
        id = 11;
        interface = "${trunk}";
      };
      lab = {
        id = 2;
        interface = "${trunk}";
      };
      common = {
        id = 5;
        interface = "${trunk}";
      };
      voip = {
        id = 6;
        interface = "${trunk}";
      };
      external = {
        id = 20;
        interface = "${trunk}";
      };
    };

    interfaces = filterAttrsRecursive (n: _: n != "info") interfaces;

    nftables = {
      enable = true;
      ruleset = ''
        define DEV_PRIVATE = enp1s0f0
        define DEV_HAM = enp2s0f1

        table ip global {

            chain inbound_world {
                #icmp type echo-request limit rate 5/second accept
                #tcp dport ssh limit rate 1/minute accept
                udp dport dhcpv6-client accept
            }

            chain inbound_private {
                icmp type echo-request limit rate 5/second accept
                ip protocol . th dport vmap {
                  tcp . 22 : accept,
                  udp . 53 : accept,
                  tcp . 53 : accept,
                  udp . 67 : accept
                }
            }

            #ct helper tftp {
            #  type "tftp" protocol udp;
            #}

            chain inbound_lab {
                icmp type echo-request limit rate 5/second accept
                #udp dport 69 ct helper set "tftp"
                ip protocol . th dport vmap {
                  tcp . 53 : accept,
                  tcp . 67 : accept,
                  udp . 53 : accept,
                  udp . 69 : accept,
                  udp . 67 : accept
                }
            }

            chain inbound {
                type filter hook input priority 0; policy drop;
                ct state vmap { established : accept, related : accept, invalid : drop }

                iifname vmap {
                  lo : accept,
                  ${wan} : jump inbound_world,
                  $DEV_PRIVATE : jump inbound_private,
                  $DEV_HAM : jump inbound_private,
                  common : jump inbound_private,
                  badwifi : jump inbound_private,
                  external : jump inbound_private,
                  voip : jump inbound_private,
                  lab : jump inbound_lab
                }
            }

            chain forward {
                type filter hook forward priority 0; policy drop;

                ct state vmap { established : accept, related : accept, invalid : drop }

                oifname $DEV_HAM iifname != $DEV_HAM drop
                iifname $DEV_PRIVATE accept
                iifname $DEV_HAM accept
                iifname common accept
                iifname badwifi accept
                iifname external accept
                iifname voip accept
                iifname lab accept
            }

            chain postrouting {
                type nat hook postrouting priority 100; policy accept;
                oifname ${wan} masquerade
            }
        }
      '';
    };
  };

  services = {
    corerad = {
      enable = true;
      settings = {
        interfaces = [
          {
            name = wan;
            monitor = true;
          }
          {
            name = "common";
            advertise = true;
            prefix = [ { prefix = "::/64"; } ];
          }
        ];
      };
    };
    tsvnstat = {
      enable = true;
      keyPath = "${config.sops.secrets.router_stats_ts_key.path}";
    };
    atftpd = {
      enable = true;
      extraOptions = [
        "--verbose=9"
        "--trace"
        "--bind-address ${(head config.networking.interfaces.lab.ipv4.addresses).address}"
      ];
    };

    dhcpd4 = {
      enable = true;
      extraConfig = ''
        option subnet-mask 255.255.255.0;
        option domain-name-servers ${concatStringsSep ", " dnsServers};

        ${concatStringsSep "\n" (
          attrValues (
            mapAttrs (intf: val: ''
              # ${intf} : ${val.info.description}
              subnet ${val.info.net} netmask ${val.info.netmask} {
                option routers ${val.info.router};
                range ${val.info.dhcp.start} ${val.info.dhcp.end};

                ${concatStringsSep "\n" (
                  map (e: ''
                    host ${e.name} {
                        hardware ethernet ${e.mac};
                        fixed-address ${e.address};
                    }
                  '') val.info.dhcp.staticIPs
                )}
              }
            '') (filterAttrsRecursive (n: _: n != "${wan}") interfaces)
          )
        )}
      '';
      interfaces = attrNames (
        filterAttrs (_: v: v.info.dhcp.enable) (filterAttrsRecursive (n: _: n != "${wan}") interfaces)
      );
      # TODO: Probably a better way to pre-filter the interfaces set
    };
  };

  environment.systemPackages = with pkgs; [
    bmon
    termshark
    tcpdump
  ];

  users.users.root = userBase;
  users.users.qbit = userBase;

  system = {
    autoUpgrade = {
      rebootWindow = {
        upper = "03:00";
        lower = "01:00";
      };
    };
    stateVersion = "22.05";
  };
}
