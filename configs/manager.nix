{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  microcaBin = "${pkgs.microca}/bin/microca";
  microca = pkgs.writeScriptBin "microca" ''
    #!/usr/bin/env sh
    ${microcaBin} -ca-key /run/secrets/ca_key -ca-cert /run/secrets/ca_cert $@
  '';
  cfg = config.nixManager;
in
  with lib; {
    options = {
      nixManager = {
        enable = mkEnableOption "Configure host as nix-conf manager.";
        user = mkOption {
          type = types.str;
          default = "root";
          description = ''
            User who will own the private key.
          '';
        };
      };
    };

    config = mkIf cfg.enable {
      sops.defaultSopsFile = config.xin-secrets.manager;
      sops.secrets = {
        xin_status_key = {owner = cfg.user;};
        xin_status_pubkey = {owner = cfg.user;};
        manager_key = {owner = cfg.user;};
        manager_pubkey = {owner = cfg.user;};
        ca_key = {owner = cfg.user;};
        ca_cert = {owner = cfg.user;};
        po_env = {owner = cfg.user;};
      };

      systemd.services.ssh-agent = {
        wantedBy = ["multi-user.target"];
        environment.SSH_AUTH_SOCK = config.environment.variables.SSH_AUTH_SOCK;
        serviceConfig = {
          ExecStartPre = "${pkgs.coreutils}/bin/rm -f $SSH_AUTH_SOCK";
          ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a $SSH_AUTH_SOCK";
          User = "${cfg.user}";
        };
      };

      systemd.services.nix-daemon.environment.SSH_AUTH_SOCK = config.environment.variables.SSH_AUTH_SOCK;
      environment.variables.SSH_AUTH_SOCK = "/tmp/ssh-agent.socket";

      environment.systemPackages = [
        microca
        inputs.xintray.packages.${pkgs.system}.xintray
        inputs.po.packages.${pkgs.system}.po
      ];
      networking = {
        hosts = {
          "66.135.2.235" = ["ns1"];
          "23.234.251.216" = ["ns2"];
          "46.23.94.18" = ["ns3"];
          "198.23.149.18" = ["ns4"];
        };
      };
    };
  }
