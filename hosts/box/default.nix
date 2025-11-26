{
  config,
  lib,
  pkgs,
  xinlib,
  ...
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
  userBase = {
    openssh.authorizedKeys.keys = pubKeys;
  };
  mkNginxSecret = {
    sopsFile = config.xin-secrets.box.secrets.certs;
    owner = config.users.users.nginx.name;
    mode = "400";
  };
in
{
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
    "bitwarden_rs.env" = {
      sopsFile = config.xin-secrets.box.secrets.services;
    };
    "wireguard_private_key" = {
      sopsFile = config.xin-secrets.box.secrets.services;
    };
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
    restic_password_file = {
      owner = "root";
      sopsFile = config.xin-secrets.box.secrets.services;
    };

    restic_env_file = {
      owner = "root";
      sopsFile = config.xin-secrets.box.secrets.services;
    };
    readeck_secret_key = {
      mode = "444";
      sopsFile = config.xin-secrets.box.secrets.services;
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

    hosts = {
      "10.6.0.1" = [ "router.bold.daemon" ];
      "127.0.0.1" = [ "git.tapenet.org" ];
      "10.6.0.15" = [
        "jelly.bold.daemon"
        "home.bold.daemon"
      ];
    };
    interfaces.enp7s0 = {
      useDHCP = true;
    };

    firewall = {
      interfaces = {
        "tailscale0" = {
          allowedTCPPorts = [
            3030
            9001
            9002
          ];
        };
      };
      interfaces = {
        "wg0" = {
          allowedTCPPorts = [
            config.services.forgejo.settings.server.SSH_PORT
            config.services.forgejo.settings.server.HTTP_PORT
            config.services.vaultwarden.config.rocketPort
          ];
        };
      };
      allowedTCPPorts = config.services.openssh.ports ++ [
        80
        443
        config.services.forgejo.settings.server.SSH_PORT
        21063 # homekit
        21064 # homekit
        1883 # mosquitto
        8123 # home-assistant
        8484 # restic-rest server
        9001
      ];
      allowedUDPPorts = [
        5353 # homekit
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
      permittedInsecurePackages = todo "remove asp/dotnet core stuff" [
        "python3.12-django-3.1.14"
        "aspnetcore-runtime-wrapped-6.0.36"
        "aspnetcore-runtime-6.0.36"
        "dotnet-sdk-wrapped-6.0.428"
        "dotnet-sdk-6.0.428"
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
        members = [
          "qbit"
          "sonarr"
          "radarr"
          "lidarr"
          "nzbget"
          "jellyfin"
          "headphones"
          "rtorrent"
          "readarr"
        ];
      };

      photos = {
        name = "photos";
        members = [ "qbit" ];
      };
    };
  };

  hardware.rtl-sdr.enable = true;

  services = {
    tsvnstat = {
      enable = true;
    };
    gotify = {
      enable = true;
      environment = {
        GOTIFY_DATABASE_DIALECT = "sqlite3";
        GOTIFY_SERVER_PORT = 8071;
      };
    };
    backups = {
      b2 = {
        enable = true;
        repository = "b2:peuwribtyRuobant8Wrinociachgum";
        environmentFile = config.sops.secrets.restic_env_file.path;
        passwordFile = config.sops.secrets.restic_password_file.path;

        paths = [
          "/home"
          "/var/lib/forgejo"
          "/var/lib/readeck"
          config.services.immich.mediaLocation
          config.services.vaultwarden.backupDir
        ];
      };
    };
    readeck = {
      enable = true;
      environmentFile = config.sops.secrets.readeck_secret_key.path;
      settings = {
        server = {
          base_url = "https://readeck.otter-alligator.ts.net";
          host = "127.0.0.1";
          port = 6784;
        };
      };
    };
    syncthing = {
      enable = true;
      user = "qbit";
      dataDir = "/home/qbit";
      settings = {
        options = {
          urAccepted = -1;
        };
        devices = config.syncthingDevices;
        folders = {
          "calibre-library" = {
            path = "~/Calibre_Library";
            id = "calibre_library";
            devices = [ "box" ];
            versioning = {
              type = "staggered";
              fsPath = "~/syncthing/calibre-backup";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
          "home/qbit/sync" = {
            path = "~/sync";
            id = "main_sync";
            devices = lib.attrNames config.syncthingDevices;
            versioning = {
              type = "staggered";
              fsPath = "~/syncthing/backup";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
        };
      };
    };
    immich = {
      enable = true;
      port = 3301;
      mediaLocation = "/media/pictures/immich";
      machine-learning.enable = true;
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
        "gotify-service" = {
          enable = true;
          funnel = true;
          reverseName = "notify";
          reversePort = config.services.gotify.environment.GOTIFY_SERVER_PORT;
          reverseIP = "127.0.0.1";
        };
        "readeck-service" = {
          enable = true;
          funnel = true;
          reverseName = "readeck";
          reversePort = config.services.readeck.settings.server.port;
          reverseIP = "127.0.0.1";
        };
        "jelly-service" = {
          enable = true;
          reverseName = "jelly";
          reversePort = 8096;
          reverseIP = "127.0.0.1";
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
          funnel = true;
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
    openssh = {
      settings.X11Forwarding = true;
    };

    tor.enable = true;

    readarr = {
      enable = true;
      dataDir = "/media/books";
      group = "media";
    };
    sonarr.enable = true;
    radarr.enable = true;
    lidarr.enable = true;
    prowlarr.enable = true;
    nzbget = {
      enable = true;
      group = "media";
      settings = {
        MainDir = "/media/downloads";
      };
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
    };

    calibre-server = {
      enable = true;
      user = "qbit";
      port = 8909;
      host = "127.0.0.1";
      libraries = [
        "/home/qbit/Calibre_Library/"
      ];
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
        ];
      };
    };

    promtail = {
      enable = false;
      configuration = {
        server = {
          http_listen_port = 3031;
          grpc_listen_port = 0;
        };
        positions = {
          filename = "/tmp/positions.yaml";
        };
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

        nginx = {
          enable = true;
        };

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
                "127.0.0.1:${toString config.services.prometheus.exporters.rtl_433.port}"
              ];
            }
          ];
        }
        {
          job_name = "box";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
              ];
            }
          ];
        }
        {
          job_name = "faf";
          static_configs = [ { targets = [ "10.6.0.245:9002" ]; } ];
        }
        {
          job_name = "h";
          static_configs = [ { targets = [ "100.83.77.133:9002" ]; } ];
        }
        {
          job_name = "pwntie";
          static_configs = [ { targets = [ "100.84.170.57:9002" ]; } ];
        }
        {
          job_name = "namish";
          static_configs = [ { targets = [ "10.200.0.100:9100" ]; } ];
        }
        {
          job_name = "nginx";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}"
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

    forgejo = {
      enable = true;
      repositoryRoot = "/media/git/repositories";
      lfs.enable = true;

      settings = {
        DEFAULT.APP_NAME = "Tape:neT";
        server = {
          DOMAIN = "git.tapenet.org";
          ROOT_URL = "https://git.tapenet.org";
          START_SSH_SERVER = true;
          SSH_SERVER_HOST_KEYS = "ssh/gitea-ed25519";
          SSH_PORT = 2222;
        };
        session = {
          COOKIE_SECURE = true;
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
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
        backup_exec	date "+ backup of /backups started at %c"
        backup	/backups/ backups/
        backup_exec	date "+ backup of /backups ended at %c"
      '';
      cronIntervals = {
        daily = "50 21 * * *";
      };
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
            proxyPass = "http://localhost:${toString config.services.calibre-web.listen.port}";
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
            proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
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

      ensureDatabases = [
        "nextcloud"
        "gitea"
        "invidious"
      ];
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
      nginx.serviceConfig = {
        ReadWritePaths = [ "/backups/nginx_cache" ];
        ReadOnlyPaths = [ "/etc/nixos/secrets" ];
      };

      forgejo.environment = {
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
