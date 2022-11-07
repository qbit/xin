{ config, lib, pkgs, ... }:
let
  microcaBin = "${pkgs.microca}/bin/microca";
  microca = pkgs.writeScriptBin "microca" ''
    #!/usr/bin/env sh
    ${microcaBin} -ca-key /run/secrets/ca_key -ca-cert /run/secrets/ca_cert $@
  '';
in with lib; {
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

  config = mkIf config.nixManager.enable {
    sops.defaultSopsFile = config.xin-secrets.manager;
    sops.secrets = {
      xin_status_key = { owner = config.nixManager.user; };
      xin_status_pubkey = { owner = config.nixManager.user; };
      manager_key = { owner = config.nixManager.user; };
      manager_pubkey = { owner = config.nixManager.user; };
      ca_key = { owner = config.nixManager.user; };
      ca_cert = { owner = config.nixManager.user; };
    };
    environment.systemPackages = [ microca ];
  };
}
