{
  config,
  lib,
  pkgs,
  inputs,
  xinlib,
  ...
}:
let
  jobs = [
    {
      name = "xin-ci-update";
      user = "qbit";
      script = "cd ~/src/xin && env SKIP_FMT=1 ./bin/ci update all";
      startAt = "*-*-01 00:00:00";
      path = [ ];
    }
    #{
    #  name = "xin-ci-update-stable";
    #  user = "qbit";
    #  script = "cd ~/src/xin && ./bin/ci update stable";
    #  startAt = "20:00";
    #  path = [ ];
    #}
    {
      name = "xin-ci";
      user = "qbit";
      script = "cd ~/src/xin && ./bin/ci";
      # systemd-analyze calendar --iterations=3 '$cronlike'
      startAt = "0/2:30:00";
      path = [ ];
    }
  ];
in
with lib;
{
  options = {
    xinCI = {
      enable = mkEnableOption "Configure host as a xin CI host.";

      user = mkOption {
        type = types.str;
        default = "root";
        description = ''
          User who will own the CI private key.
        '';
      };
    };
  };

  config = mkIf config.xinCI.enable {
    sops.defaultSopsFile = config.xin-secrets.ci;
    sops.secrets = {
      ci_ed25519_key = {
        mode = "400";
        owner = config.xinCI.user;
      };
      ci_ed25519_pub = {
        mode = "444";
        owner = config.xinCI.user;
      };
      ci_signing_ed25519_key = {
        mode = "400";
        owner = config.xinCI.user;
      };
      ci_signing_ed25519_pub = {
        mode = "444";
        owner = config.xinCI.user;
      };
      bin_cache_priv_key = {
        mode = "400";
        owner = "root";
        group = "wheel";
      };
      bin_cache_pub_key = {
        mode = "444";
        owner = "root";
        group = "wheel";
      };
      ts_proxy_env = {
        mode = "400";
        owner = config.services.ts-reverse-proxy.servers."nix-binary-cache".user;
      };
      nix_ssh_passwd = {
        mode = "400";
        owner = "root";
      };
      store_bold_daemon_cert = {
        mode = "400";
        owner = config.users.users.nginx.name;
      };
      store_bold_daemon_key = {
        mode = "400";
        owner = config.users.users.nginx.name;
      };
    };
    environment.systemPackages = with pkgs; [
      inputs.po.packages.${pkgs.system}.po
      keychain
      mosh
    ];

    networking = {
      firewall = {
        interfaces = {
          "enp10s0" = {
            allowedTCPPorts = [ 443 ]; # lan binary cache @ store.bold.daemon
          };
          "tailscale0" = {
            allowedUDPPortRanges = [
              {
                from = 60000;
                to = 61000;
              }
            ];
          };
        };
      };
    };

    nix = {
      settings.allowed-users = [
        "root"
        config.xinCI.user
        "harmonia"
        "nix-ssh"
      ];
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 60d";
      };
    };

    systemd = {
      services = lib.listToAttrs (builtins.map xinlib.jobToService jobs);
      oomd = {
        extraConfig = {
          DefaultMemoryPressureLimit = "80%";
          DefaultMemoryPressureDurationSec = "60";
        };
      };
    };

    services = {
      ts-reverse-proxy.servers."nix-binary-cache" = {
        enable = true;
      };
      nginx = {
        enable = true;
        virtualHosts = {
          "store.bold.daemon" = {
            forceSSL = true;
            sslCertificateKey = config.sops.secrets.store_bold_daemon_key.path;
            sslCertificate = config.sops.secrets.store_bold_daemon_cert.path;
            locations = {
              "/" = {
                proxyPass = "http://localhost:5000";
              };
            };
          };
        };
      };
      harmonia = {
        enable = true;
        signKeyPaths = [ config.sops.secrets.bin_cache_priv_key.path ];
        settings = {
          bind = "127.0.0.1:5000";
        };
      };
    };

    boot.binfmt.emulatedSystems = [
      "aarch64-linux"
      "armv6l-linux"
    ];
  };
}
