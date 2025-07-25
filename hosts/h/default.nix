{
  config,
  pkgs,
  isUnstable,
  inputs,
  xinlib,
  ...
}:
with pkgs;
let
  inherit (xinlib) todo;
  sojuUser = "soju";
  maxUploadSize = "150M";
  gqrss = callPackage ../../pkgs/gqrss.nix { inherit isUnstable; };
  icbirc = callPackage ../../pkgs/icbirc.nix { inherit isUnstable; };
  pgBackupDir = "/var/backups/postgresql";
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnaC1v+VoVNnK04D32H+euiCyWPXU8nX6w+4UoFfjA3 qbit@plq"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];
  userBase = {
    openssh.authorizedKeys.keys = pubKeys;
  };
  icbIrcTunnel = pkgs.writeScriptBin "icb-irc-tunnel" (
    import ../../bins/icb-irc-tunnel.nix {
      inherit pkgs;
      inherit icbirc;
    }
  );
  goModuleHost = "https://codeberg.org/qbit"; # "https://git.sr.ht/~qbit";
  httpAllow = ''
    allow	10.6.0.0/24;
    allow	100.64.0.0/10;
    allow	10.20.30.1/32;
  '';
in
{
  _module.args.isUnstable = false;

  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
      configurationLimit = 15;
    };

    kernelParams = [ "net.ifnames=0" ];
  };

  nix = {
    settings = {
      allowed-users = lib.mkForce [ "root" ];
      trusted-users = lib.mkForce [ "root" ];
    };
  };

  sops.secrets = {
    gqrss_token = {
      owner = config.users.users.qbit.name;
      mode = "400";
      sopsFile = config.xin-secrets.h.secrets.services;
    };
    restic_env_file = {
      owner = config.users.users.root.name;
      mode = "400";
      sopsFile = config.xin-secrets.h.secrets.services;
    };
    restic_password_file = {
      owner = config.users.users.root.name;
      mode = "400";
      sopsFile = config.xin-secrets.h.secrets.services;
    };
    yarr_auth = {
      owner = config.users.users.yarr.name;
      mode = "400";
      sopsFile = config.xin-secrets.h.secrets.services;
    };
    # TODO: rename
    router_stats_ts_key = {
      sopsFile = config.xin-secrets.h.secrets.services;
      owner = config.users.users.tsvnstat.name;
    };
    gostart = {
      sopsFile = config.xin-secrets.h.secrets.services;
      owner = config.users.users.gostart.name;
    };
    wireguard_private_key = {
      sopsFile = config.xin-secrets.h.secrets.services;
    };
    pots_env_file = {
      owner = config.users.users.pots.name;
      mode = "400";
      sopsFile = config.xin-secrets.h.secrets.services;
    };
    pr_status_env = {
      mode = "400";
      owner = config.services.ts-reverse-proxy.servers."pr-status-reverse".user;
      sopsFile = config.xin-secrets.h.secrets.services;
    };
    qbit_at_suah_pass_file = {
      mode = "400";
      owner = "root";
      sopsFile = config.xin-secrets.h.secrets.services;
    };
    qbit_at_segfault_pass_file = {
      mode = "400";
      owner = "root";
      sopsFile = config.xin-secrets.h.secrets.services;
    };
    mcchunkie_at_suah_pass_file = {
      mode = "400";
      owner = "root";
      sopsFile = config.xin-secrets.h.secrets.services;
    };
    bounce_cert = {
      mode = "400";
      owner = sojuUser;
      sopsFile = config.xin-secrets.h.secrets.services;
    };
    bounce_key = {
      mode = "400";
      owner = sojuUser;
      sopsFile = config.xin-secrets.h.secrets.services;
    };
    "ejabberd_matrix_key.yaml" = {
      mode = "400";
      owner = config.services.ejabberd.user;
      sopsFile = config.xin-secrets.h.secrets.services;
    };
  };

  networking = {
    hostName = "h";
    enableIPv6 = true;
    useDHCP = false;
    defaultGateway = "23.29.118.1";
    defaultGateway6 = "2602:ff16:3::1";
    nameservers = [ "9.9.9.9" ];

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
          ips = [ "192.168.112.3/32" ];
          peers = [
            {
              publicKey = "gZ16FwqUgzKgEpJgVC9BngJ+Dd0e5LPsDhDuJby0VzY=";
              allowedIPs = [ "192.168.112.4/32" ];
              persistentKeepalive = 25;
            }
          ];
          privateKeyFile = "${config.sops.secrets.wireguard_private_key.path}";
        };
      };
    };

    firewall = {
      interfaces = {
        "tailscale0" = {
          allowedTCPPorts = [
            9002
            6697
          ];
        };
      };
      allowedTCPPorts = [
        22
        80
        443

        #gitea
        2222

        # 53589

        #xmpp
        5222
        5269
        5223
        5270
        5443
        8448
      ];
      allowedUDPPorts = [ 7122 ];
      allowedUDPPortRanges = [
        {
          from = 60000;
          to = 61000;
        }
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      inetutils

      # irc
      aspell
      aspellDicts.en
      icbirc

      zonemaster-cli
      sqlite
      python3
    ];
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "aaron@bolddaemon.com";
    certs = {
      "segfault.rodeo" = {
        group = "prognx";
        extraDomainNames = [
          "upload.segfault.rodeo"
          "conference.segfault.rodeo"
          "pubsub.segfault.rodeo"
          "xmpp.segfault.rodeo"
        ];
        reloadServices = [
          "ejabberd.services"
          "nginx.service"
        ];
      };
    };
  };

  users = {
    groups = {
      ${sojuUser} = { };
      prognx = {
        members = [
          # config.services.prosody.user
          config.services.nginx.user
          config.services.ejabberd.user
        ];
      };
    };
    users = {
      root = userBase;
      qbit = { } // userBase;
      "${sojuUser}" = {
        isSystemUser = true;
        group = sojuUser;
      };
    };
  };

  systemd = {
    services = {
      soju = {
        after = [
          "network-online.target"
          "tailscaled.service"
          "icpirc.service"
        ];
        serviceConfig = {
          User = sojuUser;
          Group = sojuUser;
        };
      };
      mcchunkie = {
        after = [
          "network-online.target"
          "tailscaled.service"
        ];
      };
      nomadnet = {
        description = "nomadnet";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          User = "qbit";
          Type = "forking";
          ExecStart = "${pkgs.tmux}/bin/tmux new-session -s NomadNet -d '${pkgs.python3Packages.nomadnet}/bin/nomadnet'";
          ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t NomadNet";
        };
      };
      navidrome.serviceConfig.BindReadOnlyPaths =
        todo "navidrome dns issue: https://github.com/NixOS/nixpkgs/issues/151550"
          [ "/run/systemd/resolve/stub-resolv.conf" ];
      icb-tunnel = {
        wants = [
          "network-online.target"
          "multi-user.target"
        ];
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        serviceConfig = {
          User = "qbit";
          WorkingDirectory = "/home/qbit";
          ExecStart = "${icbIrcTunnel}/bin/icb-irc-tunnel";
        };
      };
    };
  };

  mailserver = {
    enable = true;
    fqdn = "mail.suah.dev";
    domains = [
      "suah.dev"
      "segfault.rodeo"
    ];

    certificateScheme = "acme-nginx";

    localDnsResolver = false;

    loginAccounts = {
      "qbit@segfault.rodeo" = {
        aliases = [
          "postmaster@segfault.rodeo"
          "aaron@segfault.rodeo"
        ];
        hashedPasswordFile = "${config.sops.secrets.qbit_at_segfault_pass_file.path}";
      };
      "qbit@suah.dev" = {
        hashedPasswordFile = "${config.sops.secrets.qbit_at_suah_pass_file.path}";
        aliases = [
          "postmaster@suah.dev"
          "aaron@suah.dev"
        ];
      };
      "mcchunkie@suah.dev" = {
        hashedPasswordFile = "${config.sops.secrets.mcchunkie_at_suah_pass_file.path}";
      };
    };

    fullTextSearch = {
      enable = true;
      autoIndex = true;
      enforced = "body";
    };
  };

  services = {
    ejabberd = {
      enable = true;
      package = inputs.unstable.legacyPackages.${system}.pkgs.ejabberd.override {
        withSqlite = true;
      };
      configFile = pkgs.writeText "ejabberd.yaml" (
        builtins.toJSON {
          hosts = [ "segfault.rodeo" ];
          certfiles = [
            (config.security.acme.certs."segfault.rodeo".directory + "/*.pem")
          ];

          # loglevel = "error";
          log_modules_fully = [
            "mod_matrix_gw"
          ];

          acl = {
            admin = [
              { user = "qbit@segfault.rodeo"; }
            ];
            local = {
              server = "segfault.rodeo";
            };
            loopback = {
              ip = [
                "127.0.0.0/8"
                "::1/128"
              ];
            };
          };

          access_rules = {
            configure = {
              allow = "admin";
            };
            local = {
              allow = "local";
            };
            announce = {
              allow = "admin";
            };
            trusted_network = {
              allow = "loopback";
            };
            s2s = {
              allow = "all";
            };
            c2s = {
              deny = "blocked";
              allow = "all";
            };
          };

          include_config_file = config.sops.secrets."ejabberd_matrix_key.yaml".path;

          # https://docs.ejabberd.im/admin/configuration/modules
          modules = {
            mod_adhoc = { };
            mod_admin_extra = { };
            mod_announce.access = "admin";
            mod_avatar = { };
            mod_blocking = { };
            mod_caps = { };
            mod_carboncopy = { };
            mod_client_state = { };
            mod_configure = { };
            mod_disco = { };
            mod_last = { };
            mod_mam = { };
            mod_http_upload = {
              docroot = "/var/lib/ejabberd/upload/@HOST@";
              put_url = "https://@HOST@:5443/upload";
            };
            mod_mqtt = { };
            mod_muc = {
              host = "conference.@HOST@";
            };
            mod_muc_admin = { };
            mod_muc_log = { };
            mod_offline = { };
            mod_ping = { };
            mod_pres_counter = { };
            mod_privacy = { };
            mod_private = { };
            mod_pubsub = {
              access_createnode = "pubsub_createnode";
              plugins = [
                "flat"
                "pep"
              ];
              force_node_config = {
                "stoarge:bookmarks" = {
                  access_model = "whitelist";
                };
              };
            };
            mod_push = { };
            mod_roster = { };
            mod_shared_roster = { };
            mod_stream_mgmt = { };
            mod_vcard = { };
            mod_vcard_xupdate = { };
          };

          s2s_use_starttls = "required";
          s2s_access = "s2s";

          default_db = "sql";
          sql_type = "sqlite";
          sql_database = "${config.services.ejabberd.spoolDir}/ejabberd.db";

          host_config = {
            "segfault.rodeo" = {
              auth_method = [ "internal" ];
            };
          };

          listen = [
            {
              port = 5222;
              module = "ejabberd_c2s";
              starttls = true;
              ip = "::";
            }
            {
              port = 5269;
              module = "ejabberd_s2s_in";
              ip = "::";
            }
            {
              port = 4443;
              ip = "127.0.0.1";
              module = "ejabberd_http";
              tls = false;
              request_handlers = {
                "/admin" = "ejabberd_web_admin";
              };
            }
            {
              port = 5443;
              ip = "::";
              module = "ejabberd_http";
              tls = true;
              request_handlers = {
                "/upload" = "mod_http_upload";
              };
            }
            {
              port = 8833;
              module = "mod_mqtt";
              tls = true;
              backlog = 1000;
            }
            {
              port = 8448;
              module = "ejabberd_http";
              tls = true;
              request_handlers = {
                "/_matrix" = "mod_matrix_gw";
              };
              ip = "::";
            }
          ];
        }
      );
    };
    soju = {
      enable = true;
      listen = [ "100.83.77.133:6697" ];
      hostName = "bounce.bold.daemon";
      tlsCertificate = config.sops.secrets.bounce_cert.path;
      tlsCertificateKey = config.sops.secrets.bounce_key.path;
    };
    postfix.extraConfig = ''
      smtputf8_enable = no
    '';
    smartd.enable = false;
    mcchunkie = {
      enable = true;
      disabledChats = [
        "Signal"
        "Matrix"
      ];
    };
    navidrome = {
      enable = true;
      settings = {
        Address = "127.0.0.1";
        Port = 4533;
        MusicFolder = "/var/lib/music";
        PlaylistsPath = ".:**/**";
        EnableSharing = true;
      };
    };
    ts-reverse-proxy = {
      servers = {
        "pr-status-reverse" = {
          enable = true;
          reverseName = "pr-status";
          reversePort = 3003;
        };
      };
    };
    pots = {
      enable = true;
      envFile = "${config.sops.secrets.pots_env_file.path}";
    };
    pr-status = {
      enable = true;
    };
    gostart = {
      enable = true;
      keyPath = "${config.sops.secrets.gostart.path}";
    };
    kogs = {
      enable = true;
      #registration = false;
      listen = "127.0.0.1:8383";
    };
    tsvnstat = {
      enable = true;
      #keyPath = "${config.sops.secrets.router_stats_ts_key.path}";
    };
    yarr.enable = true;
    gotosocial = {
      enable = true;
      # https://github.com/superseriousbusiness/gotosocial/blob/v0.5.2/example/config.yaml
      settings = {
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
        trusted-proxies = [
          "127.0.0.1/32"
          "23.29.118.0/24"
        ];
        landing-page-user = "qbit";
      };
    };
    prometheus = {
      enable = true;
      port = 9001;
      listenAddress = "100.83.77.133";

      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9002;
        };
      };
    };
    cron = {
      enable = true;
      systemCronJobs = [
        ''@hourly qbit  (export GH_AUTH_TOKEN=$(cat /run/secrets/gqrss_token); cd /var/www/suah.dev/rss; ${gqrss}/bin/gqrss ; ${gqrss}/bin/gqrss -search "LibreSSL" -prefix libressl_ ) >/dev/null 2>&1''
      ];
    };

    backups = {
      b2 = {
        enable = true;
        repository = "b2:cyaspanJicyeemJedMarlEjcasOmos";
        environmentFile = "${config.sops.secrets.restic_env_file.path}";
        passwordFile = "${config.sops.secrets.restic_password_file.path}";

        paths = [
          pgBackupDir
          "/var/lib/synapse/media_store"
          "/var/www"
          "/home"
          "/var/lib/yarr"
          "/var/lib/shiori"
          "/var/lib/gotosocial"
          "/var/lib/mcchunkie"
          "/var/lib/heisenbridge"
          "/var/lib/kogs"
          "/var/vmail"
          "/var/dkim"
          # config.services.prosody.dataDir
          config.services.ejabberd.spoolDir
        ];

        timerConfig = {
          OnCalendar = "00:05";
        };

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-yearly 10"
        ];
      };
    };

    nginx = {
      enable = true;

      package = pkgs.openresty;

      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      clientMaxBodySize = maxUploadSize;

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
        "ssh_gitea" = {
          servers = {
            "192.168.112.4:2222" = { };
          };
        };
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
        "paste.suah.dev" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/paste";
        };
        "sync.suah.dev" = {
          forceSSL = true;
          enableACME = true;

          locations = {
            "/" = {
              proxyPass = "http://${config.services.kogs.listen}";
              proxyWebsockets = true;
              priority = 1000;
            };
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
        "exo.suah.dev" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/exo.suah.dev";
        };

        "music.tapenet.org" = {
          forceSSL = true;
          enableACME = true;

          locations = {
            "/" = {
              proxyPass = "http://${config.services.navidrome.settings.Address}:${toString config.services.navidrome.settings.Port}";
              proxyWebsockets = true;
              priority = 1000;
            };
          };
        };

        "git.tapenet.org" = {
          forceSSL = true;
          enableACME = true;

          locations = {
            "/" = {
              proxyPass = "http://192.168.112.4:3000";
              proxyWebsockets = true;
              priority = 1000;
            };
          };
        };

        "bw.tapenet.org" = {
          forceSSL = true;
          enableACME = true;

          locations = {
            "/" = {
              proxyPass = "http://192.168.112.4:8222";
              proxyWebsockets = true;
            };
            "/admin" = {
              extraConfig = ''
                ${httpAllow}
                 deny	all;
              '';
            };
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
                proxy_set_header Authorization $http_authorization;
                proxy_pass_header Authorization;
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

            location ~ ^/_matrix/|^/_synapse/ {
                return 404;
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
        "segfault.rodeo" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/segfault.rodeo";
          locations = {
            "/.well-known/matrix/server".extraConfig = ''
              return 200 '{"m.server": "segfault.rodeo:8448"}';
            '';
          };
        };
        "mammothcirc.us" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            extraConfig = ''
              proxy_pass http://127.0.0.1:${toString config.services.gotosocial.settings.port};
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
            proxyPass = "http://${config.services.yarr.address}:${toString config.services.yarr.port}";
          };
        };
        "tapenet.org" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/tapenet.org";
          locations = {
            "/.well-known/webfinger" = {
              extraConfig = ''
                default_type 'application/json';

                content_by_lua_block {
                  local acct = ngx.unescape_uri(ngx.var.arg_resource)
                  local json = '${
                    builtins.toJSON {
                      subject = "%s";
                      links = [
                        {
                          rel = "http://openid.net/specs/connect/1.0/issuer";
                          href = "https://git.tapenet.org/";
                        }
                      ];
                    }
                  }';
                  local newjson, n, err = ngx.re.sub(json, "%s", acct)
                  if not err then
                    ngx.say(newjson)
                  else
                    ngx.say("")
                  end
                  return
                }
              '';
            };
          };
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

      settings = { };

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
      ensureDatabases = [
        "synapse"
        "gotosocial"
        "syncv3"
        "wallabag"
      ];
      ensureUsers = [
        {
          name = "synapse_user";
        }
        {
          name = "gotosocial";
          ensureDBOwnership = true;
        }
        {
          name = "syncv3";
          ensureDBOwnership = true;
        }
        {
          name = "wallabag";
          ensureDBOwnership = true;
        }
      ];
    };
  };

  system.stateVersion = "22.11";
}
