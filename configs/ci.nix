{ config, lib, pkgs, inputs, xinlib, ... }:
let
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
  patchedNixServeNg = _: super: {
    nix = super.nix-serve-ng.overrideAttrs (_: {
          patches = [
            (pkgs.fetchpatch {
              name = "initStore.patch";
              url ="https://patch-diff.githubusercontent.com/raw/aristanetworks/nix-serve-ng/pull/23.diff";
              hash = "sha256-tLIOMbqEB6zw87taqxs5zGtqgIvE0F6gxxfs8C6ShX8=";
            })
          ];
    });
  };
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
    environment.systemPackages = with pkgs; [
      inputs.po.packages.${pkgs.system}.po
      keychain
    ];

    nix = {
      settings.allowed-users = [ "root" config.xinCI.user "nix-serve" ];
    };

    systemd.services = lib.listToAttrs (builtins.map xinlib.jobToService jobs);

    nixpkgs.overlays = [
      patchedNixServeNg
    ];

    services = {
      tsrevprox = {
        enable = true;
        reverseName = "nix-binary-cache";
        envFile = config.sops.secrets.ts_proxy_env.path;
      };
      nix-serve = {
        package = pkgs.nix-serve-ng;
        enable = true;
        secretKeyFile = config.sops.secrets.bin_cache_priv_key.path;
        bindAddress = "127.0.0.1";
      };
    };

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  };
}
