{ config
, lib
, pkgs
, xinlib
, ...
}:
let
  inherit (xinlib) todo;
  httpCacheTime = "720m";
  httpAllow = ''
    allow	10.6.0.0/24;
    allow	100.64.0.0/10;
    allow	10.20.30.1/32;
  '';
  openbsdPub = {
    extraConfig = ''
      proxy_cache my_cache;
      proxy_cache_revalidate on;
      proxy_cache_min_uses 1;
      proxy_cache_use_stale error timeout updating http_500 http_502
                            http_503 http_504;
      proxy_cache_background_update on;
      proxy_cache_lock on;

      proxy_ignore_headers Cache-Control;
      proxy_cache_valid any ${httpCacheTime};

      # from jeremy
      proxy_set_header Connection "";
      proxy_http_version 1.1;

      proxy_pass http://cdn.openbsd.org;
    '';
  };

  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnaC1v+VoVNnK04D32H+euiCyWPXU8nX6w+4UoFfjA3 qbit@plq"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];
  userBase = { openssh.authorizedKeys.keys = pubKeys; };
  mkNginxSecret = {
    sopsFile = config.xin-secrets.box.secrets.certs;
    owner = config.users.users.nginx.name;
    mode = "400";
  };
in
{
  _module.args.isUnstable = true;
  imports = [
    ./hardware-configuration.nix
    #"${inputs.unstable}/nixos/modules/services/home-automation/home-assistant.nix"
  ];

  sops.secrets = {
    #nextcloud_db_pass = {
    #  owner = config.users.users.nextcloud.name;
    #  sopsFile = config.xin-secrets.box.secrets.services;
    #};
    #nextcloud_admin_pass = {
    #  owner = config.users.users.nextcloud.name;
    #  sopsFile = config.xin-secrets.box.secrets.services;
    #};
    gitea_db_pass = {
      owner = config.users.users.gitea.name;
      sopsFile = config.xin-secrets.box.secrets.services;
    };
    "bitwarden_rs.env" = { sopsFile = config.xin-secrets.box.secrets.services; };
    "wireguard_private_key" = { sopsFile = config.xin-secrets.box.secrets.services; };
    "restic_htpasswd" = {
      owner = config.users.users.restic.name;
      sopsFile = config.xin-secrets.box.secrets.services;
    };
    restic_cert = {
      owner = config.users.users.restic.name;
      sopsFile = config.xin-secrets.box.secrets.certs;
    };
    restic_key = {
      owner = config.users.users.restic.name;
      sopsFile = config.xin-secrets.box.secrets.certs;
    };

    books_cert = mkNginxSecret;
    books_key = mkNginxSecret;
    jelly_cert = mkNginxSecret;
    jelly_key = mkNginxSecret;
    lidarr_cert = mkNginxSecret;
    lidarr_key = mkNginxSecret;
    nzb_cert = mkNginxSecret;
    nzb_key = mkNginxSecret;
    prowlarr_cert = mkNginxSecret;
    prowlarr_key = mkNginxSecret;
    radarr_cert = mkNginxSecret;
    radarr_key = mkNginxSecret;
    reddit_cert = mkNginxSecret;
    reddit_key = mkNginxSecret;
    sonarr_cert = mkNginxSecret;
    sonarr_key = mkNginxSecret;
    graph_cert = mkNginxSecret;
    graph_key = mkNginxSecret;
    bw_cert = mkNginxSecret;
    bw_key = mkNginxSecret;
    readarr_cert = mkNginxSecret;
    readarr_key = mkNginxSecret;
    home_cert = mkNginxSecret;
    home_key = mkNginxSecret;
  };

  boot = {
    supportedFilesystems = [ "zfs" ];
    loader = {
      grub.copyKernels = true;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  doas.enable = true;

  networking = {
    hostName = "box";
    hostId = "9a2d2563";

    useDHCP = false;
    enableIPv6 = false;

    hosts = {
      "10.6.0.1" = [ "router.bold.daemon" ];
      "127.0.0.1" = [ "git.tapenet.org" ];
      "10.6.0.15" = [ "jelly.bold.daemon" ];
      "100.74.8.55" = [ "nix-binary-cache.otter-alligator.ts.net" ];
    };
    interfaces.enp7s0 = { useDHCP = true; };

    firewall = {
      interfaces = { "tailscale0" = { allowedTCPPorts = [ 3030 ]; }; };
      interfaces = {
        "wg0" = {
          allowedTCPPorts = [
            config.services.gitea.settings.server.SSH_PORT
            config.services.gitea.settings.server.HTTP_PORT
            config.services.vaultwarden.config.rocketPort
          ];
        };
      };
      allowedTCPPorts =
        config.services.openssh.ports
        ++ [
          80
          443
          config.services.gitea.settings.server.SSH_PORT
          21063 #homekit
          21064 #homekit
          1883 # mosquitto
          8484 # restic-rest server
        ];
      allowedUDPPorts = [
        5353 #homekit
      ];
      allowedUDPPortRanges = [
        {
          from = 60000;
          to = 61000;
        }
      ];
    };

    wireguard = {
      enable = true;
      interfaces = {
        wg0 = {
          listenPort = 7122;
          ips = [ "192.168.112.4/32" ];
          peers = [
            {
              publicKey = "IMJ1gVK6KzRghon5Wg1dxv1JCB8IbdSqeFjwQAxJM10=";
              endpoint = "23.29.118.127:7122";
              allowedIPs = [ "192.168.112.3/32" ];
              persistentKeepalive = 25;
            }
          ];
          privateKeyFile = "${config.sops.secrets.wireguard_private_key.path}";
          #privateKeyFile = "/root/wgpk";
        };
      };
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = todo "figure out what is using openssl-1.1.1w" [
        "openssl-1.1.1w"
        "aspnetcore-runtime-wrapped-6.0.36"
      ];
    };
    #overlays = [
    #  (_: _: {
    #    inherit (inputs.unstable.legacyPackages.${pkgs.system}) home-assistant;
    #  })
    #];
  };

  #disabledModules = [
  #  "services/home-automation/home-assistant.nix"
  #];

  environment = {
    systemPackages = with pkgs; [
      tmux
      mosh
      apg
      git
      signify
      git-annex
      rtl_433
    ];
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "aaron@bolddaemon.com";
  };

  users = {
    groups = {
      media = {
        name = "media";
        members = [ "qbit" "sonarr" "radarr" "lidarr" "nzbget" "jellyfin" "headphones" "rtorrent" "readarr" ];
      };

      photos = {
        name = "photos";
        members = [ "qbit" ];
      };
    };
  };

  hardware.rtl-sdr.enable = true;

  services = {
    immich = {
      enable = true;
      port = 3301;
      mediaLocation = "/media/pictures/immich";
      machine-learning.enable = true;
    };
    tsns = {
      enable = true;
    };
    rimgo = {
      enable = true;
      settings = {
        PORT = 3001;
        ADDRESS = "127.0.0.1";
      };
    };
    ts-reverse-proxy = {
      servers = {
        "invidious-service" = {
          enable = true;
          reverseName = "invidious";
          reversePort = config.services.invidious.port;
          reverseIP = config.services.invidious.address;
        };
        "rimgo-service" = {
          enable = true;
          reverseName = "rimgo";
          reversePort = config.services.rimgo.settings.PORT;
          reverseIP = config.services.rimgo.settings.ADDRESS;
        };
        "evse-service" = {
          enable = true;
          reverseName = "evse";
          reversePort = 80;
          reverseIP = "10.6.0.166";
        };
        "immich-service" = {
          enable = true;
          reverseName = "immich";
          reversePort = config.services.immich.port;
          reverseIP = config.services.immich.host;
        };
      };
    };
    restic = {
      server = {
        enable = true;
        dataDir = "/backups/restic";
        privateRepos = true;
        listenAddress = "10.6.0.15:8484";
        extraFlags = [
          "--htpasswd-file"
          "${config.sops.secrets.restic_htpasswd.path}"
          "--tls"
          "--tls-cert"
          "${config.sops.secrets.restic_cert.path}"
          "--tls-key"
          "${config.sops.secrets.restic_key.path}"
        ];
      };
    };
    mosquitto = {
      enable = true;
      listeners = [
        {
          acl = [ "pattern readwrite #" ];
          omitPasswordAuth = true;
          settings.allow_anonymous = true;
        }
      ];
    };

    avahi = {
      enable = true;
      openFirewall = true;
    };
    matter-server = {
      enable = true;
    };
    home-assistant = {
      enable = true;
      extraPackages = python3Packages:
        with python3Packages; [
          pyipp
          pymetno
          ical
          grpcio
        ];
      customComponents = [
        (pkgs.python312Packages.callPackage ../../pkgs/openevse.nix { inherit (pkgs.home-assistant) pkgs; })
      ];
      extraComponents = [
        "airthings"
        "airthings_ble"
        "airvisual"
        "airvisual_pro"
        "apple_tv"
        #"aprs"
        "brother"
        "ecobee"
        "esphome"
        "ffmpeg"
        "homekit"
        "homekit_controller"
        "icloud"
        "kodi"
        "logger"
        "matter"
        "met"
        "mqtt"
        "nextdns"
        "octoprint"
        "prometheus"
        "pushover"
        "rest"
        "snmp"
        "zeroconf"
      ];
      config = {
        sensor = [
        ];
        mqtt.sensor = [
          {
            name = "Greenhouse Temperature";
            unique_id = "greenhouse_temp_c";
            state_topic = "greenhouse/temp";
            unit_of_measurement = "°C";
          }
          {
            name = "Greenhouse Humidity";
            unique_id = "greenhouse_humidity_pct";
            state_topic = "greenhouse/humidity";
            unit_of_measurement = "%";
          }
        ];
        logger = {
          default = "warning";
          logs = {
            #"homeassistant.components.starlink" = "debug";
          };
        };
        "automation manual" = [
        ];
        "automation ui" = "!include automations.yaml";
        rest = [
          {
            resource = "http://127.0.0.1:9001/api/v1/query?query=rtl_433_temperature_celsius";
            sensor = {
              name = "rtl_433_outside";
              unique_id = "f36fc559-268f-489d-9454-56000d42ebf3";
              value_template = ''
                {% for entry in value_json.data.result %}
                  {% if entry.metric.model == 'LaCrosse-TX141Bv3' %}
                    {{ entry.value[1] }}
                  {% endif %}
                {% endfor %}
              '';
            };
          }
          {
            resource = "http://127.0.0.1:9001/api/v1/query?query=rtl_433_temperature_celsius";
            sensor = {
              unique_id = "6720a3dc-658e-496f-b321-fc9c161e6620";
              name = "rtl_433_greenhouse";
              value_template = ''
                {% for entry in value_json.data.result %}
                  {% if entry.metric.model == 'Solight-TE44' %}
                    {{ entry.value[1] }}
                  {% endif %}
                {% endfor %}
              '';
            };
          }
        ];
        device_tracker = [
        ];
        default_config = { };
        http = {
          use_x_forwarded_for = true;
          server_host = "127.0.0.1";
          trusted_proxies = "127.0.0.1";
        };
        homeassistant = {
          name = "Home";
          time_zone = "America/Denver";
          temperature_unit = "C";
          unit_system = "imperial";
          longitude = -104.72;
          latitude = 38.35;
        };
      };
    };

    invidious = {
      enable = true;
      database = {
        createLocally = true;
      };
      address = "127.0.0.1";
      port = 1538;
      settings = {
        db = {
          user = "invidious";
          password = lib.mkForce "invidious";
          dbname = "invidious";
          host = lib.mkForce "127.0.0.1";
          port = 5432;
        };
        domain = "invidious.otter-alligator.ts.net";
        https_only = true;
        popular_enabled = false;
        statistics_enabled = false;
        default_home = "Subscriptions";
      };
    };
    cron = {
      enable = true;
      systemCronJobs =
        let
          tsCertsScript = pkgs.writeScriptBin "ts-certs.sh" ''
            #!/usr/bin/env sh
            . /etc/profile;
            (
              mkdir -p /etc/nixos/secrets;
              chown root /etc/nixos/secrets/box.otter-alligator.ts.net.*;
              tailscale cert \
                --cert-file /etc/nixos/secrets/box.otter-alligator.ts.net.crt \
                --key-file=/etc/nixos/secrets/box.otter-alligator.ts.net.key \
                box.otter-alligator.ts.net;
              chown nginx /etc/nixos/secrets/box.otter-alligator.ts.net.*
            ) >/dev/null 2>&1
          '';
        in
        [ "@daily root ${tsCertsScript}/bin/ts-certs.sh" ];
    };
    openssh = { settings.X11Forwarding = true; };

    tor.enable = true;

    transmission = {
      enable = true;
      group = "media";
      downloadDirPermissions = "770";
      settings = {
        download-dir = "/media/downloads/torrents";
      };
    };
    readarr = {
      enable = true;
      dataDir = "/media/books";
      group = "media";
    };
    sonarr.enable = true;
    radarr.enable = true;
    lidarr.enable = true;
    jackett.enable = false;
    prowlarr.enable = true;
    headphones.enable = false;
    nzbget = {
      enable = true;
      group = "media";
      settings = { MainDir = "/media/downloads"; };
    };
    sabnzbd = {
      enable = true;
      group = "media";
    };

    fwupd.enable = true;
    zfs = {
      autoSnapshot = {
        enable = true;
        daily = 3;
        hourly = 8;
        monthly = 3;
        weekly = 2;
      };
    };

    jellyfin = {
      enable = true;
      openFirewall = true;
    };

    calibre-web = {
      enable = true;
      group = "media";
      options = { enableBookUploading = true; };
      listen.port = 8909;
      listen.ip = "127.0.0.1";
    };

    grafana = {
      enable = true;
      settings = {
        analytics.reporting_enabled = false;
        server = {
          domain = "graph.tapenet.org";
          http_port = 2342;
          http_addr = "127.0.0.1";
        };
      };

      #declarativePlugins = with pkgs; [ grafana-image-renderer ];

      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
          }
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:${
              toString
              config.services.loki.configuration.server.http_listen_port
            }";
          }
        ];
      };
    };

    loki = {
      enable = false;
      configuration = {
        analytics.reporting_enabled = false;
        server.http_listen_port = 3030;
        server.http_listen_address = "0.0.0.0";
        auth_enabled = false;

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore = { store = "inmemory"; };
              replication_factor = 1;
            };
          };
          chunk_idle_period = "1h";
          max_chunk_age = "1h";
          chunk_target_size = 999999;
          chunk_retain_period = "30s";
          max_transfer_retries = 0;
        };

        schema_config = {
          configs = [
            {
              from = "2022-06-06";
              store = "boltdb-shipper";
              object_store = "filesystem";
              schema = "v11";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        storage_config = {
          boltdb_shipper = {
            active_index_directory = "/var/lib/loki/boltdb-shipper-active";
            cache_location = "/var/lib/loki/boltdb-shipper-cache";
            cache_ttl = "24h";
            shared_store = "filesystem";
          };

          filesystem = { directory = "/var/lib/loki/chunks"; };
        };

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
        };

        chunk_store_config = { max_look_back_period = "0s"; };

        table_manager = {
          retention_deletes_enabled = false;
          retention_period = "0s";
        };

        compactor = {
          working_directory = "/var/lib/loki";
          shared_store = "filesystem";
          compactor_ring = { kvstore = { store = "inmemory"; }; };
        };
      };
    };

    promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 3031;
          grpc_listen_port = 0;
        };
        positions = { filename = "/tmp/positions.yaml"; };
        clients = [
          {
            url = "http://127.0.0.1:${
              toString
              config.services.loki.configuration.server.http_listen_port
            }/loki/api/v1/push";
          }
        ];
        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = "box";
              };
            };
            relabel_configs = [
              {
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "unit";
              }
            ];
          }
        ];
      };
    };

    prometheus = {
      enable = true;
      port = 9001;

      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9002;
        };

        nginx = { enable = true; };

        rtl_433 = {
          enable = true;
          group = "plugdev";
          ids = [
            {
              id = 55;
              name = "LaCrosse-TX141Bv3";
              location = "Kitchen";
            }
            {
              id = 34;
              name = "Rubicson-Temperature";
              location = "3D-Printer";
            }
          ];
        };
      };

      scrapeConfigs = [
        {
          job_name = "rtl_433";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${
                  toString config.services.prometheus.exporters.rtl_433.port
                }"
              ];
            }
          ];
        }
        {
          job_name = "box";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${
                  toString config.services.prometheus.exporters.node.port
                }"
              ];
            }
          ];
        }
        {
          job_name = "faf";
          static_configs = [{ targets = [ "10.6.0.245:9002" ]; }];
        }
        {
          job_name = "h";
          static_configs = [{ targets = [ "100.83.77.133:9002" ]; }];
        }
        {
          job_name = "pwntie";
          static_configs = [{ targets = [ "100.84.170.57:9002" ]; }];
        }
        {
          job_name = "namish";
          static_configs = [{ targets = [ "10.200.0.100:9100" ]; }];
        }
        {
          job_name = "nginx";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${
                  toString config.services.prometheus.exporters.nginx.port
                }"
              ];
            }
          ];
        }
      ];
    };

    vaultwarden = {
      enable = true;
      backupDir = "/backups/bitwarden_rs";
      config = {
        domain = "https://bw.tapenet.org";
        signupsAllowed = false;
        rocketPort = 8222;
        rocketAddress = "192.168.112.4"; # wg0
        rocketLog = "critical";
      };
      environmentFile = config.sops.secrets."bitwarden_rs.env".path;
    };

    gitea = {
      enable = true;
      stateDir = "/media/git/gitea";
      appName = "Tape:neT";

      #package = inputs.unstable.legacyPackages.${pkgs.system}.gitea;

      lfs.enable = true;

      settings = {
        server = {
          DOMAIN = "git.tapenet.org";
          ROOT_URL = "https://git.tapenet.org";
          START_SSH_SERVER = true;
          SSH_SERVER_HOST_KEYS = "ssh/gitea-ed25519";
          SSH_PORT = 2222;
          DISABLE_REGISTRATION = true;
          COOKIE_SECURE = true;
        };
      };

      database = {
        type = "postgres";
        passwordFile = "${config.sops.secrets.gitea_db_pass.path}";
        socket = "/run/postgresql";
      };
    };

    rsnapshot = {
      enable = true;
      enableManualRsnapshot = true;
      extraConfig = ''
        snapshot_root	/external/snapshots/
        retain	daily	7
        retain	manual	3
        backup_exec	date "+ backup of /media started at %c"
        backup	/media/	media/
        backup_exec	date "+ backup of /media ended at %c"
        backup_exec	date "+ backup of /var started at %c"
        backup	/var/	var/
        backup_exec	date "+ backup of /var ended at %c"
      '';
      cronIntervals = { daily = "50 21 * * *"; };
    };

    redlib = {
      enable = true;
      port = 8482;
    };

    nginx = {
      enable = true;

      statusPage = true;

      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      clientMaxBodySize = "512M";

      commonHttpConfig = ''
        proxy_cache_path /backups/nginx_cache levels=1:2 keys_zone=my_cache:10m max_size=10g
                 inactive=${httpCacheTime} use_temp_path=off;
      '';

      virtualHosts = {
        "home.bold.daemon" = {
          forceSSL = true;
          sslCertificateKey = "${config.sops.secrets.home_key.path}";
          sslCertificate = "${config.sops.secrets.home_cert.path}";
          extraConfig = ''
            proxy_buffering off;
          '';
          locations."/" = {
            proxyPass = "http://127.0.0.1:8123";
            proxyWebsockets = true;
          };
        };
        "box.otter-alligator.ts.net" = {
          forceSSL = true;
          sslCertificateKey = "/etc/nixos/secrets/box.otter-alligator.ts.net.key";
          sslCertificate = "/etc/nixos/secrets/box.otter-alligator.ts.net.crt";

          locations."/photos" = {
            proxyPass = "http://localhost:2343";
            proxyWebsockets = true;
          };

          locations."/pub" = openbsdPub;
        };

        #"photos.tapenet.org" = {
        #  forceSSL = true;
        #  enableACME = true;

        #  locations."/" = {
        #    proxyPass = "http://localhost:2343";
        #    proxyWebsockets = true;
        #  };
        #};

        "jelly.bold.daemon" = {
          forceSSL = true;
          sslCertificateKey = "${config.sops.secrets.jelly_key.path}";
          sslCertificate = "${config.sops.secrets.jelly_cert.path}";

          locations."/" = {
            # TODO: jellyfin.nix doesn't expose the port being used.
            proxyPass = "http://localhost:8096";
            proxyWebsockets = true;
            extraConfig = ''
              ${httpAllow}
               deny	all;
            '';
          };
        };

        "reddit.bold.daemon" = {
          sslCertificateKey = "${config.sops.secrets.reddit_key.path}";
          sslCertificate = "${config.sops.secrets.reddit_cert.path}";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:${toString config.services.redlib.port}";
            proxyWebsockets = true;
            extraConfig = ''
              ${httpAllow}
               deny	all;
            '';
          };
        };

        "books.bold.daemon" = {
          sslCertificateKey = "${config.sops.secrets.books_key.path}";
          sslCertificate = "${config.sops.secrets.books_cert.path}";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:${
              toString config.services.calibre-web.listen.port
            }";
            proxyWebsockets = true;
            extraConfig = ''
              ${httpAllow}
               deny	all;
            '';
          };
        };

        "sonarr.bold.daemon" = {
          sslCertificateKey = "${config.sops.secrets.sonarr_key.path}";
          sslCertificate = "${config.sops.secrets.sonarr_cert.path}";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:8989";
            proxyWebsockets = true;
            extraConfig = ''
              ${httpAllow}
               deny	all;
            '';
          };
        };
        "radarr.bold.daemon" = {
          sslCertificateKey = "${config.sops.secrets.radarr_key.path}";
          sslCertificate = "${config.sops.secrets.radarr_cert.path}";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:7878";
            proxyWebsockets = true;
            extraConfig = ''
              ${httpAllow}
               deny	all;
            '';
          };
        };
        "prowlarr.bold.daemon" = {
          sslCertificateKey = "${config.sops.secrets.prowlarr_key.path}";
          sslCertificate = "${config.sops.secrets.prowlarr_cert.path}";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:9696";
            proxyWebsockets = true;
            extraConfig = ''
              ${httpAllow}
               deny	all;
            '';
          };
        };
        "nzb.bold.daemon" = {
          sslCertificateKey = "${config.sops.secrets.nzb_key.path}";
          sslCertificate = "${config.sops.secrets.nzb_cert.path}";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:8080";
            proxyWebsockets = true;
            extraConfig = ''
              ${httpAllow}
               deny	all;
            '';
          };
        };
        "headphones.bold.daemon" = {
          locations."/" = {
            proxyPass = "http://localhost:8181";
            proxyWebsockets = true;
            extraConfig = ''
              ${httpAllow}
               deny	all;
            '';
          };
        };
        "lidarr.bold.daemon" = {
          sslCertificateKey = "${config.sops.secrets.lidarr_key.path}";
          sslCertificate = "${config.sops.secrets.lidarr_cert.path}";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:8686";
            proxyWebsockets = true;
            extraConfig = ''
              ${httpAllow}
               deny	all;
            '';
          };
        };
        "readarr.bold.daemon" = {
          sslCertificateKey = "${config.sops.secrets.readarr_key.path}";
          sslCertificate = "${config.sops.secrets.readarr_cert.path}";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://localhost:8787";
            proxyWebsockets = true;
            extraConfig = ''
              ${httpAllow}
               deny	all;
            '';
          };
        };

        "graph.bold.daemon" = {
          sslCertificateKey = "${config.sops.secrets.graph_key.path}";
          sslCertificate = "${config.sops.secrets.graph_cert.path}";
          forceSSL = true;

          locations."/" = {
            proxyPass = "http://127.0.0.1:${
              toString config.services.grafana.settings.server.http_port
            }";
            proxyWebsockets = true;
            extraConfig = ''
              ${httpAllow}
               deny	all;
            '';
          };
        };
      };
    };

    postgresqlBackup = {
      enable = true;
      location = "/backups/postgresql";
    };
    postgresql = {
      enable = true;
      #dataDir = "/db/postgres";

      package = pkgs.postgresql_16;

      enableTCPIP = true;
      authentication = pkgs.lib.mkOverride 14 ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all ::1/128 trust
      '';

      ensureDatabases = [ "nextcloud" "gitea" "invidious" ];
      ensureUsers = [
        {
          name = "nextcloud";
          ensureDBOwnership = true;
        }
        {
          name = "gitea";
          ensureDBOwnership = true;
        }
        {
          name = "invidious";
          ensureDBOwnership = true;
        }
      ];
    };
  };

  systemd = {
    services = {
      tsns = {
        serviceConfig = {
          Restart = "always";
          RestartSecs = 15;
        };
      };
      nginx.serviceConfig = {
        ReadWritePaths = [ "/backups/nginx_cache" ];
        ReadOnlyPaths = [ "/etc/nixos/secrets" ];
      };

      gitea.environment = {
        GIT_CONFIG_NOGLOBAL = "true";
        GIT_CONFIG_NOSYSTEM = "true";
      };
      #"nextcloud-setup" = {
      #  requires = [ "postgresql.service" ];
      #  after = [ "postgresql.service" ];
      #};
    };
  };

  users.users = {
    qbit = userBase;
    root = userBase;
  };

  programs.zsh.enable = true;

  system.stateVersion = "20.03";
}
