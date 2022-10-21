{ config, pkgs, lib, ... }:
let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];
  userBase = { openssh.authorizedKeys.keys = pubKeys; };

  wan = "enp5s0f0";
  trunk = "enp5s0f1";
  interfaces = {
    "${wan}" = { useDHCP = true; };
    "${trunk}" = rec {
      ipv4.addresses = [{
        address = "10.99.99.1";
        prefixLength = 24;
      }];
      info = {
        route = false;
        network =
          "10.99.99.0/${toString (builtins.head ipv4.addresses).prefixLength}";
      };
    };
    enp1s0f0 = rec {
      ipv4.addresses = [{
        address = "10.99.1.1";
        prefixLength = 24;
      }];
      info = {
        route = true;
        network =
          "10.99.1.0/${toString (builtins.head ipv4.addresses).prefixLength}";
      };
    };
    enp2s0f1 = rec {
      ipv4.addresses = [{
        address = "10.98.1.1";
        prefixLength = 24;
      }];
      info = {
        route = false;
        network =
          "10.98.1.0/${toString (builtins.head ipv4.addresses).prefixLength}";
      };
    };
    badwifi = rec {
      ipv4.addresses = [{
        address = "10.10.0.1";
        prefixLength = 24;
      }];
      info = {
        route = true;
        network =
          "10.10.0.0/${toString (builtins.head ipv4.addresses).prefixLength}";
      };
    };
    goodwifi = rec {
      ipv4.addresses = [{
        address = "10.12.0.1";
        prefixLength = 24;
      }];
      info = {
        route = false;
        network =
          "10.12.0.0/${toString (builtins.head ipv4.addresses).prefixLength}";
      };
    };
    lab = rec {
      ipv4.addresses = [{
        address = "10.3.0.1";
        prefixLength = 24;
      }];
      info = {
        route = true;
        network =
          "10.3.0.0/${toString (builtins.head ipv4.addresses).prefixLength}";
      };
    };
    external = rec {
      ipv4.addresses = [{
        address = "10.20.30.1";
        prefixLength = 24;
      }];
      info = {
        route = true;
        network =
          "10.20.30.0/${toString (builtins.head ipv4.addresses).prefixLength}";
      };
    };
    common = rec {
      ipv4.addresses = [{
        address = "10.6.0.1";
        prefixLength = 24;
      }];
      info = {
        route = true;
        vlanID = 5;
        network =
          "10.6.0.0/${toString (builtins.head ipv4.addresses).prefixLength}";
      };
    };
    voip = rec {
      ipv4.addresses = [{
        address = "10.7.0.1";
        prefixLength = 24;
      }];
      info = {
        route = true;
        network =
          "10.7.0.0/${toString (builtins.head ipv4.addresses).prefixLength}";
      };
    };
  };
in {
  _module.args.isUnstable = false;
  imports = [ ./hardware-configuration.nix ];

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  autoUpdate.enable = false;

  sops.secrets = {
    wireguard_private_key = {
      sopsFile = config.xin-secrets.router.networking;
    };
  };

  networking = {
    hostName = "router";

    useDHCP = false;
    firewall.enable = false;

    wireguard = {
      enable = false;
      interfaces = {
        wg0 = {
          listenPort = 7122;
          ips = [ "192.168.112.4/32" ];
          peers = [{
            publicKey = "CEnjIUpeOEZ9nUvuA1HCDg3duE/OPcdvJpbEsX1dXBM=";
            endpoint = "107.191.42.21:7122";
            allowedIPs = [ "0.0.0.0/0" ];
            persistentKeepalive = 25;
          }];
          privateKeyFile = "${config.sops.secrets.wireguard_private_key.path}";
        };
      };
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

    interfaces =
      lib.attrsets.filterAttrsRecursive (n: v: n != "info") interfaces;

    nftables = {
      enable = true;
      ruleset = ''
        define DEV_PRIVATE = enp1s0f0
        define DEV_HAM = enp2s0f1

        table ip global {

            chain inbound_world {
                #icmp type echo-request limit rate 5/second accept
                tcp dport ssh limit rate 1/minute accept
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

            chain inbound {
                type filter hook input priority 0; policy drop;
                ct state vmap { established : accept, related : accept, invalid : drop }

                iifname vmap {
                  lo : accept,
                  ${wan} : jump inbound_world,
                  $DEV_PRIVATE : jump inbound_private,
                  $DEV_HAM : jump inbound_private,
                  common : jump inbound_private,
                  badwifi : jump inbound_private
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
            }

            chain postrouting {
                type nat hook postrouting priority 100; policy accept;
                oifname ${wan} masquerade
            }
        }
      '';
    };
  };

  services.atftpd = {
    enable = true;
    extraOptions = [
      "--bind-address ${
        (builtins.head config.networking.interfaces.lab.ipv4.addresses).address
      }"
    ];
  };

  services.dhcpd4 = {
    enable = true;
    extraConfig = ''
      option subnet-mask 255.255.255.0;
      option domain-name-servers 45.90.28.147, 45.90.30.147;
      subnet 10.99.1.0 netmask 255.255.255.0 {
          option routers 10.99.1.1;
          range 10.99.1.100 10.99.1.199;
      }

      subnet 10.98.1.0 netmask 255.255.255.0 {
          option routers 10.98.1.1;
          range 10.98.1.100 10.98.1.199;
      }

      subnet 10.6.0.0 netmask 255.255.255.0 {
          option routers 10.6.0.1;
          range 10.6.0.10 10.6.0.199;
      }

      subnet 10.10.0.0 netmask 255.255.255.0 {
          option routers 10.10.0.1;
          range 10.10.0.10 10.10.0.199;
      }

    '';
    interfaces = [ "enp1s0f0" "enp2s0f1" "common" "badwifi" ];
  };

  environment.systemPackages = with pkgs; [ tcpdump ];

  users.users.root = userBase;
  users.users.qbit = userBase;

  system = {
    autoUpgrade = {
      allowReboot = true;
      rebootWindow = {
        upper = "03:00";
        lower = "01:00";
      };
    };
    stateVersion = "22.05";
  };
}

