{ config, ... }:
let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPMaAm4rDxyU975Z54YiNw3itC2fGc3SaE2VaS1fai8 root@box"
  ];
  userBase = {
    openssh.authorizedKeys.keys = pubKeys ++ config.myconf.managementPubKeys;
  };
in
{
  _module.args.isUnstable = false;
  imports = [ ./hardware-configuration.nix ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    supportedFilesystems = [ "zfs" ];
    zfs.devNodes = "/dev/";
  };

  networking = {
    hostName = "faf";
    hostId = "12963a2a";

    useDHCP = false;
    interfaces.enp1s0.useDHCP = true;
    interfaces.enp2s0.useDHCP = true;

    firewall = {
      allowedTCPPorts = [ 22 53 config.services.prometheus.exporters.node.port ];
      allowedUDPPorts = [ 53 ];
    };
    hosts = { "100.74.8.55" = [ "nix-binary-cache.otter-alligator.ts.net" ]; };
  };

  users.users = {
    root = userBase;
  };

  services = {
    prometheus = {
      enable = true;
      port = 9001;

      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9002;
        };
      };
    };
    adguardhome = {
      enable = false;
      openFirewall = true;
      settings = {
        bind_port = 3000;
        user_rules = [
          "# Stuff from kyle"
          "# some google stuff that wasn't being blocked"
          "||googleadservices.com^"
          "||imasdk.googleapis.com^"
          "# some advertising stuff I saw on my network"
          "||adjust.com^"
          "||appsflyer.com^"
          "||doubleclick.net^"
          "||googleadservices.com^"
          "||raygun.io^"
          "||pizzaseo.com^"
          "||scorecardresearch.com^"
          "# annoying website 'features'"
          "||drift.com^"
          "||driftcdn.com^"
          "||driftt.com^"
          "||driftt.imgix.net^"
          "||intercomcdn.com^"
          "||intercom.io^"
          "||salesforceliveagent.com^"
          "||viafoura.co^"
          "||viafoura.com^"
        ];
        filters = [
          {
            name = "AdGuard DNS filter";
            url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt";
            enabled = true;
          }
          {
            name = "AdaAway Default Blocklist";
            url = "https://adaway.org/hosts.txt";
            enabled = true;
          }
          {
            name = "OISD";
            url = "https://abp.oisd.nl";
            enabled = true;
          }
        ];
        dns = {
          statistics_interval = 90;
          bind_host = "10.6.0.245";
          bootstrap_dns = "10.6.0.1";
        };
      };
    };
    unbound = {
      enable = true;
      settings = {
        server = {
          interface = [ "100.80.94.131" ];
          access-control = [ "100.64.0.0/10 allow" ];
        };
        local-zone = ''"bold.daemon." static'';
        local-data = [
          ''"books.bold.daemon. IN A 100.115.16.150"''
          ''"headphones.bold.daemon. IN A 100.115.16.150"''
          ''"jelly.bold.daemon. IN A 100.115.16.150"''
          ''"lidarr.bold.daemon. IN A 100.115.16.150"''
          ''"nzb.bold.daemon. IN A 100.115.16.150"''
          ''"prowlarr.bold.daemon. IN A 100.115.16.150"''
          ''"radarr.bold.daemon. IN A 100.115.16.150"''
          ''"reddit.bold.daemon. IN A 100.115.16.150"''
          ''"sonarr.bold.daemon. IN A 100.115.16.150"''
          ''"readarr.bold.daemon. IN A 100.115.16.150"''
          ''"home.bold.daemon. IN A 100.115.16.150"''
          ''"graph.bold.daemon. IN A 100.115.16.150"''
          ''"invidious.bold.daemon. IN A 100.115.16.150"''
          ''"backup.bold.daemon. IN A 10.6.0.15"''
          ''"router.bold.daemon. IN A 10.6.0.1"''
          ''"cake.bold.daemon. IN A 10.6.0.144"''
        ];
      };
    };
  };

  system.stateVersion = "21.11"; # Did you read the comment?
}
