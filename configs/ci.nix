{ config
, lib
, pkgs
, inputs
, xinlib
, ...
}:
let
  #inherit (xinlib) prIsOpen;
  jobs = [
    {
      name = "xin-ci-update";
      user = "qbit";
      script = "cd ~/src/xin && ./bin/ci update";
      startAt = "Mon,Thu 23:00";
      path = [ ];
    }
    {
      name = "xin-ci";
      user = "qbit";
      script = "cd ~/src/xin && ./bin/ci";
      startAt = "*:30:00";
      path = [ ];
    }
  ];
in
with lib; {
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
      po_env = { owner = config.xinCI.user; };
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
    };
    environment.systemPackages = with pkgs; [
      inputs.po.packages.${pkgs.system}.po
      keychain
      mosh
    ];

    networking = {
      firewall = {
        interfaces = {
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
      settings.allowed-users = [ "root" config.xinCI.user "harmonia" ];
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 60d";
      };
    };

    systemd.services = lib.listToAttrs (builtins.map xinlib.jobToService jobs);

    services = {
      ts-reverse-proxy.servers."nix-binary-cache" = {
        enable = true;
      };
      harmonia = {
        enable = true;
        signKeyPath = config.sops.secrets.bin_cache_priv_key.path;
        settings = { bind = "127.0.0.1:5000"; };
      };
    };

    boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv6l-linux" ];
  };
}
