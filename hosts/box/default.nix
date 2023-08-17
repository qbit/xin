{
  inputs,
  config,
  lib,
  pkgs,
  isUnstable,
  ...
}: let
  #photoPrismTag = "220901-bullseye";
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

      proxy_pass http://ftp.usa.openbsd.org;
    '';
  };

  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnaC1v+VoVNnK04D32H+euiCyWPXU8nX6w+4UoFfjA3 qbit@plq"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];
  userBase = {openssh.authorizedKeys.keys = pubKeys;};
  mkNginxSecret = {
    sopsFile = config.xin-secrets.box.certs;
    owner = config.users.users.nginx.name;
    mode = "400";
  };
in {
  _module.args.isUnstable = false;
  imports = [
    ./hardware-configuration.nix
    "${inputs.unstable}/nixos/modules/services/home-automation/home-assistant.nix"
  ];

  sops.secrets = {
    #nextcloud_db_pass = {
    #  owner = config.users.users.nextcloud.name;
    #  sopsFile = config.xin-secrets.box.services;
    #};
    #nextcloud_admin_pass = {
    #  owner = config.users.users.nextcloud.name;
    #  sopsFile = config.xin-secrets.box.services;
    #};
    #photoprism_admin_password = {sopsFile = config.xin-secrets.box.services;};
    gitea_db_pass = {
      owner = config.users.users.gitea.name;
      sopsFile = config.xin-secrets.box.services;
    };
    "bitwarden_rs.env" = {sopsFile = config.xin-secrets.box.services;};
    "wireguard_private_key" = {sopsFile = config.xin-secrets.box.services;};
  };

  sops.secrets.books_cert = mkNginxSecret;
  sops.secrets.books_key = mkNginxSecret;
  sops.secrets.jelly_cert = mkNginxSecret;
  sops.secrets.jelly_key = mkNginxSecret;
  sops.secrets.lidarr_cert = mkNginxSecret;
  sops.secrets.lidarr_key = mkNginxSecret;
  sops.secrets.nzb_cert = mkNginxSecret;
  sops.secrets.nzb_key = mkNginxSecret;
  sops.secrets.prowlarr_cert = mkNginxSecret;
  sops.secrets.prowlarr_key = mkNginxSecret;
  sops.secrets.radarr_cert = mkNginxSecret;
  sops.secrets.radarr_key = mkNginxSecret;
  sops.secrets.reddit_cert = mkNginxSecret;
  sops.secrets.reddit_key = mkNginxSecret;
  sops.secrets.sonarr_cert = mkNginxSecret;
  sops.secrets.sonarr_key = mkNginxSecret;
  sops.secrets.graph_cert = mkNginxSecret;
  sops.secrets.graph_key = mkNginxSecret;
  sops.secrets.bw_cert = mkNginxSecret;
  sops.secrets.bw_key = mkNginxSecret;
  sops.secrets.invidious_cert = mkNginxSecret;
  sops.secrets.invidious_key = mkNginxSecret;
  sops.secrets.readarr_cert = mkNginxSecret;
  sops.secrets.readarr_key = mkNginxSecret;
  sops.secrets.home_cert = mkNginxSecret;
  sops.secrets.home_key = mkNginxSecret;

  boot.supportedFilesystems = ["zfs"];
  boot.loader.grub.copyKernels = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  doas.enable = true;

  networking = {
    hostName = "box";
    hostId = "9a2d2563";

    useDHCP = false;
    enableIPv6 = false;

    hosts = {
      "127.0.0.1" = ["git.tapenet.org"];
      "10.6.0.15" = ["jelly.bold.daemon"];
      "100.122.61.43" = ["nix-binary-cache.humpback-trout.ts.net"];
    };
    interfaces.enp7s0 = {useDHCP = true;};

    firewall = {
      interfaces = {"tailscale0" = {allowedTCPPorts = [3030];};};
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
          ips = ["192.168.112.4/32"];
          peers = [
            {
              publicKey = "IMJ1gVK6KzRghon5Wg1dxv1JCB8IbdSqeFjwQAxJM10=";
              endpoint = "23.29.118.127:7122";
              allowedIPs = ["192.168.112.3/32"];
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
    config.allowUnfree = true;
    overlays = [
      (_: _: {
        inherit (inputs.unstable.legacyPackages.${pkgs.system}) home-assistant;
      })
    ];
  };

  disabledModules = [
    "services/home-automation/home-assistant.nix"
  ];

  environment.systemPackages = with pkgs; [
    tmux
    mosh
    apg
    git
    signify
    glowing-bear
    rtl_433

    (callPackage ../../pkgs/athens.nix {inherit isUnstable;})
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "aaron@bolddaemon.com";
  };

  users.groups.media = {
    name = "media";
    members = ["qbit" "sonarr" "radarr" "lidarr" "nzbget" "jellyfin" "headphones" "rtorrent" "readarr"];
  };

  users.groups.photos = {
    name = "photos";
    members = ["qbit"];
  };

  users.groups.photoprism = {
    name = "photoprism";
    gid = 986;
  };
  users.users.photoprism = {
    uid = 991;
    name = "photoprism";
    isSystemUser = true;
    hashedPassword = null;
    group = "photoprism";
    shell = "/bin/sh";
    openssh.authorizedKeys.keys = pubKeys;
  };

  systemd.services.photoprism = {
    serviceConfig = {
      WorkingDirectory = lib.mkForce "/media/pictures/photoprism";
    };
    preStart = lib.mkForce "";
  };

  hardware.rtl-sdr.enable = true;

  services = {
    mosquitto = {
      enable = true;
      listeners = [
        {
          acl = ["pattern readwrite #"];
          omitPasswordAuth = true;
          settings.allow_anonymous = true;
        }
      ];
    };

    avahi = {
      enable = true;
      openFirewall = true;
    };
    home-assistant = {
      enable = true;
      extraPackages = python3Packages:
        with python3Packages; [
          pyipp
          pymetno
        ];
      extraComponents = [
        "airthings"
        "airthings_ble"
        "airvisual"
        "airvisual_pro"
        "apple_tv"
        #"aprs"
        "brother"
        "esphome"
        "ffmpeg"
        "homekit"
        "homekit_controller"
        "icloud"
        "jellyfin"
        "logger"
        "met"
        "mqtt"
        "nextdns"
        "openevse"
        "prometheus"
        "pushover"
        "rest"
        "snmp"
        "zeroconf"
      ];
      config = {
        mqtt.sensor = [
        ];
        logger = {
          default = "warning";
          logs = {
            #"homeassistant.components.aprs" = "debug";
          };
        };
        "automation manual" = [
        ];
        "automation ui" = "!include automations.yaml";
        rest = [
          {
            resource = "http://127.0.0.1:9001/api/v1/query?query=rtl_433_temperature_celsius";
            sensor = {
              name = "rtl_433_temperature_celsius";
              value_template = "{{value_json.data.result[0].value[1]}}";
            };
          }
        ];
        device_tracker = [
        ];
        default_config = {};
        http = {
          use_x_forwarded_for = true;
          server_host = "127.0.0.1";
          trusted_proxies = "127.0.0.1";
        };
        homeassistant = {
          name = "Home";
          time_zone = "America/Denver";
          temperature_unit = "C";
          unit_system = "metric";
          longitude = -104.72;
          latitude = 38.35;
        };
      };
    };
    #photoprism = {
    #  enable = true;
    #  port = 2343;
    #  storagePath = "/media/pictures/photoprism/storage";
    #  originalsPath = "/media/pictures/photoprism/originals";
    #  importPath = "/media/pictures/photoprism/import";
    #  settings = {
    #    PHOTOPRISM_UPLOAD_NSFW = "true";
    #    PHOTOPRISM_DETECT_NSFW = "false";
    #    PHOTOPRISM_SITE_URL = "https://box.humpback-trout.ts.net/photos";
    #    PHOTOPRISM_SETTINGS_HIDDEN = "false";
    #    PHOTOPRISM_DATABASE_DRIVER = "sqlite";
    #  };
    #};
    #nextcloud = {
    #  enable = true;
    #  enableBrokenCiphersForSSE = false;
    #  hostName = "box.humpback-trout.ts.net";
    #  home = "/media/nextcloud";
    #  https = true;

    #  package = pkgs.nextcloud27;
    #  extraApps = with config.services.nextcloud.package.packages.apps; {
    #    inherit bookmarks calendar contacts notes tasks twofactor_webauthn;
    #  };

    #  extraAppsEnable = true;

    #  config = {
    #    overwriteProtocol = "https";

    #    dbtype = "pgsql";
    #    dbuser = "nextcloud";
    #    dbhost = "/run/postgresql";
    #    dbname = "nextcloud";
    #    dbpassFile = "${config.sops.secrets.nextcloud_db_pass.path}";

    #    adminpassFile = "${config.sops.secrets.nextcloud_admin_pass.path}";
    #    adminuser = "admin";
    #  };
    #};
    invidious = {
      enable = true;
      settings = {
        port = lib.mkForce 1538;
        host_binding = "127.0.0.1";
        domain = "invidious.bold.daemon";
        https_only = true;
        popular_enabled = false;
        statistics_enabled = false;
        default_home = "Subscriptions";
      };
    };
    cron = {
      enable = true;
      systemCronJobs = let
        tsCertsScript = pkgs.writeScriptBin "ts-certs.sh" ''
          #!/usr/bin/env sh
          . /etc/profile;
          (
            mkdir -p /etc/nixos/secrets;
            chown root /etc/nixos/secrets/box.humpback-trout.ts.net.*;
            tailscale cert \
              --cert-file /etc/nixos/secrets/box.humpback-trout.ts.net.crt \
              --key-file=/etc/nixos/secrets/box.humpback-trout.ts.net.key \
              box.humpback-trout.ts.net;
            chown nginx /etc/nixos/secrets/box.humpback-trout.ts.net.*
          ) >/dev/null 2>&1
        '';
      in ["@daily root ${tsCertsScript}/bin/ts-certs.sh"];
    };
    openssh = {settings.X11Forwarding = true;};

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
      settings = {MainDir = "/media/downloads";};
    };

    fwupd.enable = true;
    zfs = {
      autoSnapshot.enable = true;
      autoReplication = {
        enable = true;
        host = "10.6.0.245";
        identityFilePath = "/etc/ssh/ssh_host_ed25519_key";
        localFilesystem = "rpool";
        recursive = true;
        remoteFilesystem = "tank/backups/box";
        username = "root";
      };
    };

    jellyfin = {
      enable = true;
      openFirewall = true;
    };

    calibre-web = {
      enable = true;
      group = "media";
      options = {enableBookUploading = true;};
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
      enable = true;
      configuration = {
        analytics.reporting_enabled = false;
        server.http_listen_port = 3030;
        server.http_listen_address = "0.0.0.0";
        auth_enabled = false;

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore = {store = "inmemory";};
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

          filesystem = {directory = "/var/lib/loki/chunks";};
        };

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
        };

        chunk_store_config = {max_look_back_period = "0s";};

        table_manager = {
          retention_deletes_enabled = false;
          retention_period = "0s";
        };

        compactor = {
          working_directory = "/var/lib/loki";
          shared_store = "filesystem";
          compactor_ring = {kvstore = {store = "inmemory";};};
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
        positions = {filename = "/tmp/positions.yaml";};
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
                source_labels = ["__journal__systemd_unit"];
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
          enabledCollectors = ["systemd"];
          port = 9002;
        };

        nginx = {enable = true;};

        rtl_433 = {
          enable = true;
          group = "plugdev";
          ids = [
            {
              id = 55;
              name = "LaCrosse-TX141Bv3";
              location = "Kitchen";
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
          job_name = "greenhouse";
          static_configs = [{targets = ["10.6.0.20:80"];}];
        }
        {
          job_name = "house";
          static_configs = [{targets = ["10.6.0.21:80"];}];
        }
        {
          job_name = "outside";
          static_configs = [{targets = ["10.6.0.22:8811"];}];
        }
        {
          job_name = "faf";
          static_configs = [{targets = ["10.6.0.245:9002"];}];
        }
        {
          job_name = "h";
          static_configs = [{targets = ["100.64.247.69:9002"];}];
        }
        {
          job_name = "namish";
          static_configs = [{targets = ["10.200.0.100:9100"];}];
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
      stateDir = "/media/git";
      appName = "Tape:neT";

      package = inputs.unstable.legacyPackages.${pkgs.system}.forgejo;

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
      enable = false;
      enableManualRsnapshot = true;
      extraConfig = ''
        snapshot_root	/backups/snapshots/
        retain	daily	7
        retain	manual	3
        backup_exec	date "+ backup of suah.dev started at %c"
        backup	root@suah.dev:/home/	suah.dev/
        backup	root@suah.dev:/etc/	suah.dev/
        backup	root@suah.dev:/var/synapse/	suah.dev/
        backup	root@suah.dev:/var/dendrite/	suah.dev/
        backup	root@suah.dev:/var/hammer/	suah.dev/
        backup	root@suah.dev:/var/go-ipfs/	suah.dev/
        backup	root@suah.dev:/var/gopher/	suah.dev/
        backup	root@suah.dev:/var/honk/	suah.dev/
        backup	root@suah.dev:/var/mcchunkie/	suah.dev/
        backup	root@suah.dev:/var/www/	suah.dev/
        backup_exec	date "+ backup of suah.dev ended at %c"
      '';
      cronIntervals = {daily = "50 21 * * *";};
    };

    libreddit = {
      enable = true;
      port = 8482;
    };

    nginx = {
      enable = true;
      package = pkgs.openresty;

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
        "invidious.bold.daemon" = {
          forceSSL = true;
          sslCertificateKey = "${config.sops.secrets.invidious_key.path}";
          sslCertificate = "${config.sops.secrets.invidious_cert.path}";
          locations."/" = {
            proxyPass = "http://127.0.0.1:${
              toString config.services.invidious.settings.port
            }";
            proxyWebsockets = true;
          };
        };
        "box.humpback-trout.ts.net" = {
          forceSSL = true;
          sslCertificateKey = "/etc/nixos/secrets/box.humpback-trout.ts.net.key";
          sslCertificate = "/etc/nixos/secrets/box.humpback-trout.ts.net.crt";

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
            proxyPass = "http://localhost:${toString config.services.libreddit.port}";
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
            proxyPass = "http://localhost:6789";
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

          locations."/_pub" = {
            extraConfig = ''
               default_type 'application/json';

              content_by_lua_block {
                       function lsplit (str, sep)
                         sep = "\n"
                         local t={}
                         for str in string.gmatch(str, "([^"..sep.."]+)") do
                           table.insert(t, str)
                         end
                         return t
                       end

                       local sock = ngx.socket.tcp()
                       local ok, err = sock:connect("127.0.0.1", ${
                toString config.services.prometheus.port
              })
                       if not ok then
                           ngx.say("failed to connect to backend: ", err)
                           return
                       end

                       local bytes = sock:send("GET /api/v1/query?query=wstation_temp_c HTTP/1.1\nHost: 127.0.0.1:${
                toString config.services.prometheus.port
              }\n\n")

                       sock:settimeouts(1000, 1000, 1000)

                       local data, err = sock:receiveany(10 * 1024)
                       if not data then
                         ngx.say("failed to read weather data: ", err)
                         return
                       end

               local b = lsplit(data)
                       ngx.say(b[#b])

                       sock:close()
              }
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
      dataDir = "/db/postgres";

      #enableTCPIP = true;
      #authentication = pkgs.lib.mkOverride 14 ''
      #  local all all trust
      #  host all all 127.0.0.1/32 trust
      #  host all all ::1/128 trust
      #'';

      ensureDatabases = ["nextcloud" "gitea" "invidious"];
      ensureUsers = [
        {
          name = "nextcloud";
          ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
        }
        {
          name = "gitea";
          ensurePermissions."DATABASE gitea" = "ALL PRIVILEGES";
        }
        {
          name = "invidious";
          ensurePermissions."DATABASE invidious" = "ALL PRIVILEGES";
        }
      ];
    };
  };

  systemd.services.nginx.serviceConfig = {
    ReadWritePaths = ["/backups/nginx_cache"];
    ReadOnlyPaths = ["/etc/nixos/secrets"];
  };

  systemd.services.gitea.environment = {
    GIT_CONFIG_NOGLOBAL = "true";
    GIT_CONFIG_NOSYSTEM = "true";
  };

  #systemd.services."nextcloud-setup" = {
  #  requires = [ "postgresql.service" ];
  #  after = [ "postgresql.service" ];
  #};

  users.users.qbit = userBase;
  users.users.root = userBase;

  programs.zsh.enable = true;

  system.stateVersion = "20.03";
}
