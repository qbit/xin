{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  microcaBin = "${pkgs.microca}/bin/microca";
  microca = pkgs.writeScriptBin "microca" ''
    #!/usr/bin/env sh
    ${microcaBin} -ca-key /run/secrets/ca_key -ca-cert /run/secrets/ca_cert $@
  '';
  mkXinHost = hostList: map (host: { inherit host; }) hostList;
in
with lib;
{
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

  imports = [ ./tailnet.nix ];

  config = mkIf config.nixManager.enable {
    programs.xin-status = {
      enable = true;
      settings = {
        repository = "/home/qbit/src/xin";
        privKeyPath = "/run/secrets/xin_status_key";
        flakeRss = "https://github.com/qbit/xin/commits/main.atom";
        statuses = [
          {
            name = "stan";
            host = "10.6.0.224";
          }
        ]
        ++ (mkXinHost [
          "europa"
          "h"
          "orcim"
          "box"
          "pwntie"
        ]);
        ciHost = "pwntie";
      };
    };
    sops.secrets = {
      xin_status_key = {
        owner = config.nixManager.user;
        sopsFile = config.xin-secrets.manager;
      };
      xin_status_pubkey = {
        owner = config.nixManager.user;
        sopsFile = config.xin-secrets.manager;
      };
      manager_key = {
        owner = config.nixManager.user;
        sopsFile = config.xin-secrets.manager;
      };
      manager_pubkey = {
        owner = config.nixManager.user;
        sopsFile = config.xin-secrets.manager;
      };
      ca_key = {
        owner = config.nixManager.user;
        sopsFile = config.xin-secrets.manager;
      };
      ca_cert = {
        owner = config.nixManager.user;
        sopsFile = config.xin-secrets.manager;
      };
    };

    environment.systemPackages = [
      microca
      inputs.po.packages.${pkgs.stdenv.hostPlatform.system}.po
    ];

    networking = {
      hosts = {
        "66.135.2.235" = [ "ns1" ];
        "142.171.43.82" = [ "ns2" ];
        "64.176.200.236" = [ "ns3" ];
        "198.23.149.18" = [ "ns4" ];
      };
    };
  };
}
