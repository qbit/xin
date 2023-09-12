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
      startAt = "23:00";
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
        owner = config.services.tsrevprox.user;
      };
    };
    environment.systemPackages = with pkgs; [
      inputs.po.packages.${pkgs.system}.po
      keychain
    ];

    nix = {
      #settings.allowed-users = [ "root" config.xinCI.user "nix-serve" ];
      settings.allowed-users = [ "root" config.xinCI.user "harmonia" ];
    };

    systemd.services = lib.listToAttrs (builtins.map xinlib.jobToService jobs);

    services = {
      tsrevprox = {
        enable = true;
        reverseName = "nix-binary-cache";
        envFile = config.sops.secrets.ts_proxy_env.path;
      };
      harmonia = {
        enable = true;
        signKeyPath = config.sops.secrets.bin_cache_priv_key.path;
        settings = { bind = "127.0.0.1:5000"; };
      };
      #nix-serve = {
      #  package = pkgs.nix-serve-ng;
      #  enable = true;
      #  secretKeyFile = config.sops.secrets.bin_cache_priv_key.path;
      #  bindAddress = "127.0.0.1";
      #};
    };

    boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv6l-linux" ];
  };
}
