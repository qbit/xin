{ config, pkgs, ... }:
let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];
  userBase = { openssh.authorizedKeys.keys = pubKeys; };

  wan = "enp5s0f0";
  trunk = "enp5s0f1";
in {
  _module.args.isUnstable = false;
  imports = [ ./hardware-configuration.nix ];

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  sops.secrets = {
    wireguard_private_key = {
      sopsFile = config.xin-secrets.router.networking;
    };
  };

  networking = {
    hostName = "router";

    useDHCP = false;
    firewall.enable = false;

    nftables = {
      enable = true;
      rulesetFile = ./router.nft;
    };

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

    interfaces = {
      "${wan}" = { useDHCP = true; };

      "${trunk}" = {
        ipv4.addresses = [{
          address = "10.99.99.1";
          prefixLength = 24;
        }];
      };

      enp1s0f0 = {
        ipv4.addresses = [{
          address = "10.99.1.1";
          prefixLength = 24;
        }];
      };

      badwifi = {
        ipv4.addresses = [{
          address = "10.10.0.1";
          prefixLength = 24;
        }];
      };
      goodwifi = {
        ipv4.addresses = [{
          address = "10.12.0.1";
          prefixLength = 24;
        }];
      };
      lab = {
        ipv4.addresses = [{
          address = "10.3.0.1";
          prefixLength = 24;
        }];
      };
      external = {
        ipv4.addresses = [{
          address = "10.20.30.1";
          prefixLength = 24;
        }];
      };
      #common = {
      #  ipv4.addresses = [{
      #    address = "10.6.0.1";
      #    prefixLength = 24;
      #  }];
      #};
      voip = {
        ipv4.addresses = [{
          address = "10.7.0.1";
          prefixLength = 24;
        }];
      };
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
      option routers 10.99.1.1;
      option domain-name-servers 9.9.9.9;
      subnet 10.99.1.0 netmask 255.255.255.0 {
          range 10.99.1.100 10.99.1.199;
      }
    '';
    interfaces = [ "enp1s0f0" ];
  };

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

