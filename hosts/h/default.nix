{
  config,
  pkgs,
  isUnstable,
  ...
}:
with pkgs; let
  restic = pkgs.writeScriptBin "restic" (import ../../bins/restic.nix {
    inherit pkgs;
    inherit lib;
    inherit config;
  });
  gqrss = callPackage ../../pkgs/gqrss.nix {inherit isUnstable;};
  icbirc = callPackage ../../pkgs/icbirc.nix {inherit isUnstable;};
  mcchunkie = callPackage ../../pkgs/mcchunkie.nix {inherit isUnstable;};
  slidingSyncPkg = callPackage ../../pkgs/sliding-sync.nix {};
  weepushover =
    python3Packages.callPackage ../../pkgs/weepushover.nix {inherit pkgs;};
  pgBackupDir = "/var/backups/postgresql";
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnaC1v+VoVNnK04D32H+euiCyWPXU8nX6w+4UoFfjA3 qbit@plq"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];
  userBase = {openssh.authorizedKeys.keys = pubKeys;};
  icbIrcTunnel =
    pkgs.writeScriptBin "icb-irc-tunnel"
    (import ../../bins/icb-irc-tunnel.nix {
      inherit pkgs;
      inherit icbirc;
    });
  goModuleHost = "https://codeberg.org/qbit"; # "https://git.sr.ht/~qbit";
  httpAllow = ''
    allow	10.6.0.0/24;
    allow	100.64.0.0/10;
    allow	10.20.30.1/32;
  '';

  mtxCfg = {
    port = 8009;
    address = "127.0.0.1";
  };

  matrixServer = "tapenet.org";
  matrixClientConfig = {
    "m.homeserver".base_url = "https://${matrixServer}:443";
    "org.matrix.msc3575.proxy" = {url = "https://${matrixServer}";};
  };
  matrixServerConfig = {"m.server" = "${matrixServer}:443";};
  mkMatrixWellKnown = p: ''
    return 200 '${builtins.toJSON p}';
  '';

  mkMatrixSliderLoc = {
    proxyWebsockets = true;
    proxyPass = "http://${config.services.sliding-sync.address}:${
      toString config.services.sliding-sync.port
    }";
  };
  mkMatrixLoc = {
    proxyWebsockets = true;
    proxyPass = "http://${mtxCfg.address}:${toString mtxCfg.port}";
  };
in {
  _module.args.isUnstable = false;
  imports = [
    ./hardware-configuration.nix
    ../../modules/gotosocial.nix
    ../../modules/yarr.nix
    ../../modules/tsvnstat.nix
    ../../modules/golink.nix
    ../../modules/sliding-sync.nix
    ../../modules/ts-rev-prox.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.configurationLimit = 15;

  boot.kernelParams = ["net.ifnames=0"];

  tailscale.sshOnly = true;

  nixpkgs.overlays = [
    (_: super: {
      weechat = super.weechat.override {
        configure = {...}: {
          scripts = with super.weechatScripts; [highmon weepushover];
        };
      };
    })
  ];

  sops.secrets = {
    synapse_signing_key = {
      owner = config.users.users.matrix-synapse.name;
      mode = "600";
      sopsFile = config.xin-secrets.h.services;
    };
    hammer_access_token = {
      owner = config.users.users.mjolnir.name;
      mode = "600";
      sopsFile = config.xin-secrets.h.services;
    };
    gqrss_token = {
      owner = config.users.users.qbit.name;
      mode = "400";
      sopsFile = config.xin-secrets.h.services;
    };
    restic_env_file = {
      owner = config.users.users.root.name;
      mode = "400";
      sopsFile = config.xin-secrets.h.services;
    };
    restic_password_file = {
      owner = config.users.users.root.name;
      mode = "400";
      sopsFile = config.xin-secrets.h.services;
    };
    yarr_auth = {
      owner = config.users.users.yarr.name;
      mode = "400";
      sopsFile = config.xin-secrets.h.services;
    };
    # TODO: rename
    router_stats_ts_key = {
      sopsFile = config.xin-secrets.h.services;
      owner = config.users.users.tsvnstat.name;
    };
    golink = {
      sopsFile = config.xin-secrets.h.services;
      owner = config.users.users.golink.name;
    };
    gostart = {
      sopsFile = config.xin-secrets.h.services;
      owner = config.users.users.gostart.name;
    };
    wireguard_private_key = {sopsFile = config.xin-secrets.h.services;};
    pots_env_file = {
      owner = config.users.users.pots.name;
      mode = "400";
      sopsFile = config.xin-secrets.h.services;
    };
    sliding_sync_env = {
      owner = config.services.sliding-sync.user;
      mode = "400";
      sopsFile = config.xin-secrets.h.services;
    };
    pr_status_env = {
      mode = "400";
      owner = config.services.tsrevprox.user;
      sopsFile = config.xin-secrets.h.services;
    };
  };

  networking = {
    hostName = "h";
    enableIPv6 = true;
    useDHCP = false;
    defaultGateway = "23.29.118.1";
    defaultGateway6 = "2602:ff16:3::1";
    nameservers = ["9.9.9.9"];

    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "23.29.118.127";
          prefixLength = 24;
        }
      ];
      ipv6 = {
        addresses = [
          {
            address = "2602:ff16:3:0:1:3a0:0:1";
            prefixLength = 64;
          }
        ];
      };
    };

    wireguard = {
      enable = true;
      interfaces = {
        wg0 = {
          listenPort = 7122;
          ips = ["192.168.112.3/32"];
          peers = [
            {
              publicKey = "gZ16FwqUgzKgEpJgVC9BngJ+Dd0e5LPsDhDuJby0VzY=";
              allowedIPs = ["192.168.112.4/32"];
              persistentKeepalive = 25;
            }
          ];
          privateKeyFile = "${config.sops.secrets.wireguard_private_key.path}";
        };
      };
    };

    firewall = {
      interfaces = {"tailscale0" = {allowedTCPPorts = [9002];};};
      allowedTCPPorts = [22 80 443 2222 53589];
      allowedUDPPorts = [7122];
      allowedUDPPortRanges = [
        {
          from = 60000;
          to = 61000;
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    inetutils

    # irc
    weechat
    weechatScripts.highmon
    aspell
    aspellDicts.en
    icbirc

    # matrix things
    matrix-synapse-tools.synadm
    matrix-synapse-tools.rust-synapse-compress-state
    mcchunkie

    restic
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "aaron@bolddaemon.com";
  };

  users.groups.mcchunkie = {};

  users.users.mcchunkie = {
    createHome = true;
    isSystemUser = true;
    home = "/var/lib/mcchunkie";
    group = "mcchunkie";
  };

  systemd.services.icb-tunnel = {
    wantedBy = ["network.target"];
    after = ["network.target" "multi-user.target"];
    serviceConfig = {
      User = "qbit";
      WorkingDirectory = "/home/qbit";
      ExecStart = "${icbIrcTunnel}/bin/icb-irc-tunnel";
    };
  };

  systemd.services.mcchunkie = {
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      User = "mcchunkie";
      Group = "mcchunkie";
      Restart = "always";
      WorkingDirectory = "/var/lib/mcchunkie";
      ExecStart = "${mcchunkie}/bin/mcchunkie";
    };
  };

  services = {
    heisenbridge = {
      enable = true;
      homeserver = "http://${mtxCfg.address}:${toString mtxCfg.port}";
      owner = "@qbit:tapenet.org";
      namespaces = {
        users = [
          {
            regex = "@irc_.*";
            exclusive = true;
          }
        ];
        aliases = [];
        rooms = [];
      };
    };
    tsrevprox = {
      enable = true;
      reverseName = "pr-status";
      reversePort = 3003;
      envFile = config.sops.secrets.pr_status_env.path;
    };
    sliding-sync = {
      enable = true;
      server = "https://tapenet.org";
      package = slidingSyncPkg;
    };
    pots = {
      enable = true;
      envFile = "${config.sops.secrets.pots_env_file.path}";
    };
    pr-status = {enable = true;};
    gostart = {
      enable = true;
      keyPath = "${config.sops.secrets.gostart.path}";
    };
    golink = {
      enable = true;
      envFile = "${config.sops.secrets.golink.path}";
    };
    tsvnstat = {
      enable = true;
      keyPath = "${config.sops.secrets.router_stats_ts_key.path}";
    };
    yarr.enable = true;
    gotosocial = {
      enable = true;
      # https://github.com/superseriousbusiness/gotosocial/blob/v0.5.2/example/config.yaml
      configuration = {
        account-domain = "mammothcirc.us";
        accounts-approval-required = false;
        accounts-reason-required = false;
        accounts-registration-open = false;
        accounts-allow-custom-css = true;
        advanced-cookies-samesite = "strict";
        bind-address = "127.0.0.1";
        db-address = "127.0.0.1";
        db-database = "gotosocial";
        db-port = 5432;
        db-tls-ca-cert = "";
        db-type = "postgres";
        db-user = "gotosocial";
        dp-password = "";
        host = "mammothcirc.us";
        log-db-queries = true;
        log-level = "debug";
        port = 8778;
        protocol = "https";
        storage-backend = "local";
        storage-local-base-path = "/var/lib/gotosocial";
        trusted-proxies = ["127.0.0.1/32" "23.29.118.0/24"];
        web-template-base-dir = "${config.services.gotosocial.package}/assets/web/template/";
        web-asset-base-dir = "${config.services.gotosocial.package}/assets/web/assets/";
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
        clients = [{url = "http://box.humpback-trout.ts.net:3030/loki/api/v1/push";}];
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
      listenAddress = "100.64.247.69";

      exporters = {
        node = {
          enable = true;
          enabledCollectors = ["systemd"];
          port = 9002;
        };
      };
    };
    taskserver = {
      enable = true;
      fqdn = "tasks.suah.dev";
      listenHost = "::";
      organisations."bolddaemon".users = ["qbit"];
      openFirewall = false;
    };
    cron = {
      enable = true;
      systemCronJobs = [
        ''
          @hourly qbit  (export GH_AUTH_TOKEN=$(cat /run/secrets/gqrss_token); cd /var/www/suah.dev/rss; ${gqrss}/bin/gqrss ; ${gqrss}/bin/gqrss -search "LibreSSL" -prefix libressl_ ) >/dev/null 2>&1''
      ];
    };

    restic = {
      backups = {
        b2 = {
          initialize = true;
          repository = "b2:cyaspanJicyeemJedMarlEjcasOmos";
          environmentFile = "${config.sops.secrets.restic_env_file.path}";
          passwordFile = "${config.sops.secrets.restic_password_file.path}";

          paths = [
            pgBackupDir
            "/var/lib/synapse/media_store"
            "/var/www"
            "/home"
            "/var/lib/yarr"
            "/var/lib/gotosocial"
            "/var/lib/mcchunkie"
            "/var/lib/taskserver"
            "/var/lib/heisenbridge"
          ];

          timerConfig = {OnCalendar = "00:05";};

          pruneOpts = ["--keep-daily 7" "--keep-weekly 5" "--keep-yearly 10"];
        };
      };
    };

    nginx = {
      enable = true;

      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      clientMaxBodySize = "50M";

      commonHttpConfig = ''
        # Add HSTS header with preloading to HTTPS requests.
        # Adding this header to HTTP requests is discouraged
        map $scheme $hsts_header {
            https   "max-age=31536000; includeSubdomains; preload";
        }
        add_header Strict-Transport-Security $hsts_header;

        # Enable CSP for your services.
        #add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;

        # Minimize information leaked to other domains
        add_header 'Referrer-Policy' 'origin-when-cross-origin';

        # Disable embedding as a frame
        add_header X-Frame-Options DENY;

        # Prevent injection of code in other mime types (XSS Attacks)
        add_header X-Content-Type-Options nosniff;

        # This might create errors
        proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
      '';

      upstreams = {
        "ssh_gitea" = {servers = {"192.168.112.4:2222" = {};};};
      };

      streamConfig = ''
        server {
          listen 23.29.118.127:2222;
          proxy_pass 192.168.112.4:2222;
        }
      '';

      virtualHosts = {
        "deftly.net" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/deftly.net";
          extraConfig = ''
            location ~ ^/pub|^/patches|^/dist|^/pbp|^/screenshots|^/pharo|^/fw {
              autoindex on;
              index index.php index.html index.htm;
            }
          '';
        };
        "bolddaemon.com" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/bolddaemon.com";
        };
        "relay.bolddaemon.com" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/bolddaemon.com";
          locations."/weechat" = {
            proxyWebsockets = true;
            proxyPass = "http://localhost:9009/weechat";
          };
        };
        "notes.suah.dev" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/suah.dev";
          extraConfig = ''
            location / {
              resolver 9.9.9.9;
              proxy_set_header Connection "";
              proxy_http_version 1.1;
              proxy_pass https://publish.obsidian.md/serve?url=notes.suah.dev/;
              proxy_ssl_server_name on;
            }
          '';
        };

        "bear.tapenet.org" = {
          forceSSL = true;
          enableACME = true;

          locations."/" = {root = "${pkgs.glowing-bear}";};
        };

        "git.tapenet.org" = {
          forceSSL = true;
          enableACME = true;

          locations."/" = {
            proxyPass = "http://192.168.112.4:3000";
            proxyWebsockets = true;
            priority = 1000;
          };
        };

        "bw.tapenet.org" = {
          forceSSL = true;
          enableACME = true;

          locations."/" = {
            proxyPass = "http://192.168.112.4:8222";
            proxyWebsockets = true;
          };
          locations."/admin" = {
            extraConfig = ''
              ${httpAllow}
               deny	all;
            '';
          };
        };

        "suah.dev" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/suah.dev";
          extraConfig = ''
                      location ~ ^/api {
                              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                              proxy_set_header Host $host:$server_port;
                              proxy_set_header X-Forwarded-Proto $scheme;
                              proxy_set_header X-Forwarded-Ssl on;
                              proxy_read_timeout 300;
                              proxy_connect_timeout 300;
                              proxy_pass http://127.0.0.1:8888; # pots
                      }
                      location ~ ^/_got {
                              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                              proxy_set_header Host $host:$server_port;
                              proxy_set_header X-Forwarded-Proto $scheme;
                              proxy_set_header X-Forwarded-Ssl on;
                              proxy_read_timeout 300;
                              proxy_connect_timeout 300;
                              proxy_pass http://127.0.0.1:8043;
                      }

                      location ~ ^/_sms {
                              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                              proxy_set_header Host $host:$server_port;
                              proxy_set_header X-Forwarded-Proto $scheme;
                              proxy_set_header X-Forwarded-Ssl on;
                              proxy_read_timeout 300;
                              proxy_connect_timeout 300;
                              proxy_pass http://127.0.0.1:8044;
                      }
            location ~ ^/p/ {
            	autoindex		on;
            }

            location ~ ^/recipes/ {
            	autoindex		on;
            }

            location ~* .(xml)$ {
            	autoindex		on;
            	root			/var/www/suah.dev/rss;
            }

                      location ~ "([^/\s]+)(/.*)?" {
                            set $not_serving 1;

                            if ($request_filename = 'index.html') {
                                    set $not_serving 0;
                            }

                            if (-f $request_filename) {
                                    set $not_serving 0;
                            }

                            if ($args = "go-get=1") {
                                    add_header Strict-Transport-Security $hsts_header;
                                    add_header Referrer-Policy origin-when-cross-origin;
                                    add_header X-Frame-Options DENY;
                                    add_header X-Content-Type-Options nosniff;
                                    add_header Content-Type text/html;
                                    return 200 '<html><head>
                                      <meta name="go-import" content="$host/$1 git ${goModuleHost}/$1">
                                      <meta name="go-source" content="$host/$1 _ ${goModuleHost}/$1/tree/master{/dir} ${goModuleHost}/$1/tree/master{/dir}/{file}#L{line}">
                                      <meta http-equiv="refresh" content="0; url=https://pkg.go.dev/mod/suah.dev/$1">
                                      </head>
                                      <body>
                                      Redirecting to docs at <a href="https://pkg.go.dev/mod/suah.dev/$1">pkg.go.dev/mod/suah.dev/$1</a>...
                                      </body>
                                      </html>';
                            }
                            if ($not_serving) {
                                    add_header Strict-Transport-Security $hsts_header;
                                    add_header Referrer-Policy origin-when-cross-origin;
                                    add_header X-Frame-Options DENY;
                                    add_header X-Content-Type-Options nosniff;
                                    add_header Content-Type text/html;
                                    return 200 '<html><head>
                                      <meta name="go-import" content="$host/$1 git ${goModuleHost}/$1">
                                      <meta name="go-source" content="$host/$1 _ ${goModuleHost}/$1/tree/master{/dir} ${goModuleHost}/$1/tree/master{/dir}/{file}#L{line}">
                                      <meta http-equiv="refresh" content="0; url=https://pkg.go.dev/mod/suah.dev/$1">
                                      </head>
                                      <body>
                                      Redirecting to docs at <a href="https://pkg.go.dev/mod/suah.dev/$1">pkg.go.dev/mod/suah.dev/$1</a>...
                                      </body>
                                      </html>';
                            }
                          }
          '';
        };
        "qbit.io" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/qbit.io";
        };
        "mammothcirc.us" = {
          forceSSL = true;
          enableACME = true;
          extraConfig =
            if config.services.gotosocial.package.version == "0.7.1"
            then ''
              # TODO: This can be removed next release
              # https://github.com/superseriousbusiness/gotosocial/issues/1419
              # Workaround for missing API + Ice Cubes
              location ~ ^/api/v1/accounts/[0-9A-Z]+/featured_tags {
                  default_type application/json;
                  return 200 '[]';
              }
            ''
            else "";
          locations."/" = {
            extraConfig = ''
              proxy_pass http://127.0.0.1:${
                toString config.services.gotosocial.configuration.port
              };
              proxy_set_header Host $host;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
              proxy_set_header X-Forwarded-For $remote_addr;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };
        "mammothcircus.com" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/mammothcircus.com";
        };
        "rss.bolddaemon.com" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/rss.bolddaemon.com";
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "http://${config.services.yarr.address}:${
              toString config.services.yarr.port
            }";
          };
        };
        "tapenet.org" =
          if config.services.sliding-sync.enable
          then {
            forceSSL = true;
            enableACME = true;
            root = "/var/www/tapenet.org";
            locations."/.well-known/matrix/client".extraConfig =
              mkMatrixWellKnown matrixClientConfig;
            locations."/.well-known/matrix/server".extraConfig =
              mkMatrixWellKnown matrixServerConfig;

            locations."/client" = mkMatrixSliderLoc;
            locations."/_matrix/client/unstable/org.matrix.msc3575/sync" =
              mkMatrixSliderLoc;

            locations."/_matrix" = mkMatrixLoc;
            locations."/_synapse/client" = mkMatrixLoc;
          }
          else {
            forceSSL = true;
            enableACME = true;
            root = "/var/www/tapenet.org";
            locations."/.well-known/matrix/client".extraConfig =
              mkMatrixWellKnown matrixClientConfig;
            locations."/.well-known/matrix/server".extraConfig =
              mkMatrixWellKnown matrixServerConfig;

            locations."/_matrix" = mkMatrixLoc;
            locations."/_synapse/client" = mkMatrixLoc;
          };
      };
    };

    postgresqlBackup = {
      enable = true;
      location = pgBackupDir;
    };

    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;

      settings = {};

      enableTCPIP = true;
      authentication = pkgs.lib.mkOverride 14 ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all ::1/128 trust
      '';

      initialScript = pkgs.writeText "synapse-init.sql" ''
        CREATE ROLE "synapse-user" LOGIN;
        CREATE DATABASE "synapse" WITH OWNER "synapse-user"
          TEMPLATE template0
          LC_COLLATE = "C"
          LC_CTYPE = "C";
      '';
      ensureDatabases = ["synapse" "gotosocial" "syncv3"];
      ensureUsers = [
        {
          name = "synapse_user";
          ensurePermissions."DATABASE synapse" = "ALL PRIVILEGES";
        }
        {
          name = "gotosocial";
          ensurePermissions."DATABASE gotosocial" = "ALL PRIVILEGES";
        }
        {
          name = "syncv3";
          ensurePermissions."DATABASE syncv3" = "ALL PRIVILEGES";
        }
      ];
    };

    mjolnir = {
      enable = true;
      pantalaimon.enable = false;
      pantalaimon.username = "hammer";
      accessTokenFile = "${config.sops.secrets.hammer_access_token.path}";
      homeserverUrl = "https://tapenet.org";
      protectedRooms = [
        "https://matrix.to/#/#openbsd:matrix.org"
        "https://matrix.to/#/#go-lang:matrix.org"
        "https://matrix.to/#/#plan9:matrix.org"
        "https://matrix.to/#/#nix-openbsd:tapenet.org"
        "https://matrix.to/#/#cobug:tapenet.org"
      ];
      settings = {
        verboseLogging = false;
        protections = {
          wordlist = {
            words = [
              "^https://libera.chat <-- visit!$"
              "^@.*@.*@.*@.*@.*@.*@.*@.*@.*@.*"
            ];
          };
        };
        managementRoom = "#moderation:tapenet.org";
        automaticallyRedactForReasons = [
          "spam"
          "advertising"
          "racism"
          "nazi"
          "nazism"
          "trolling"
          "porn"
          "csam"
        ];
        aditionalPrefixes = ["hammer"];
        confirmWildcardBan = false;
      };
    };

    matrix-synapse = {
      enable = true;
      dataDir = "/var/lib/synapse";
      settings = {
        enable_registration = false;
        media_store_path = "/var/lib/synapse/media_store";
        presence.enabled = false;
        public_baseurl = "https://tapenet.org";
        server_name = "tapenet.org";
        signing_key_path = "${config.sops.secrets.synapse_signing_key.path}";
        url_preview_enabled = false;
        plugins = with config.services.matrix-synapse.package.plugins; [matrix-synapse-mjolnir-antispam];
        app_service_config_files = [
          "/var/lib/heisenbridge/registration.yml"
        ];
        database = {
          name = "psycopg2";
          args = {
            database = "synapse";
            user = "synapse_user";
          };
        };
        listeners = [
          {
            bind_addresses = [mtxCfg.address];
            port = mtxCfg.port;
            resources = [
              {
                compress = true;
                names = ["client"];
              }
              {
                compress = false;
                names = ["federation"];
              }
            ];
            tls = false;
            type = "http";
            x_forwarded = true;
          }
        ];
      };
    };
  };

  users.users.qbit = userBase;

  system.stateVersion = "22.11";
}
