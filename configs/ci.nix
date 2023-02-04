{ config, lib, pkgs, inputs, xinlib, ... }:
let
  jobs = [
    {
      name = "xin-ci-update";
      script = "cd ~/src/xin && ./ci update";
      startAt = "00,12:00:00";
      path = [ ];
    }
    {
      name = "xin-ci";
      script = "cd ~/src/xin && ./ci";
      startAt = "*:30:00";
      path = [ ];
    }
  ];
in with lib; {
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

  imports = [ ../modules/ts-rev-prox.nix ];
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
        owner = config.services.tsrevprox.user;
      };
    };
    environment.systemPackages = [ inputs.po.packages.${pkgs.system}.po ];

    nix = {
      settings.allowed-users = [ "root" config.xinCI.user "nix-serve" ];
    };

    systemd.user.services =
      lib.listToAttrs (builtins.map xinlib.jobToService jobs);

    services = {
      tsrevprox = {
        enable = true;
        reverseName = "nix-binary-cache";
        envFile = config.sops.secrets.ts_proxy_env.path;
      };
      nix-serve = {
        package = pkgs.nix-serve.override {
          nix =
            inputs.unstable.legacyPackages.x86_64-linux.nixVersions.nix_2_12;
        };
        enable = true;
        secretKeyFile = config.sops.secrets.bin_cache_priv_key.path;
        bindAddress = "127.0.0.1";
      };
    };

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  };
}
