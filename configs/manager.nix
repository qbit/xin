{ config
, lib
, pkgs
, inputs
, ...
}:
let
  cfg = config.nixManager;
  microcaBin = "${pkgs.microca}/bin/microca";
  microca = pkgs.writeScriptBin "microca" ''
    #!/usr/bin/env sh
    ${microcaBin} -ca-key /run/secrets/ca_key -ca-cert /run/secrets/ca_cert $@
  '';
in
with lib; {
  options = {
    nixManager = {
      enable = mkEnableOption "Configure host as nix-conf manager.";
      user = mkOption {
        type = types.str;
        default = "mgr";
        description = ''
          User who will own the private key.
        '';
      };
    };
  };

  #imports = [ ./tailnet.nix ];

  config = mkIf cfg.enable {
    users.users.mgr = {
      isNormalUser = true;
      description = "Nix Manager";
      home = "/home/mgr";
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
    sops.defaultSopsFile = config.xin-secrets.manager;
    sops.secrets = {
      xin_status_key = { owner = cfg.user; };
      xin_status_pubkey = { owner = cfg.user; };
      manager_key = { owner = cfg.user; };
      manager_pubkey = { owner = cfg.user; };
      ca_key = { owner = cfg.user; };
      ca_cert = { owner = cfg.user; };
      po_env = { owner = cfg.user; };
    };

    environment.systemPackages = [
      microca
      inputs.xintray.packages.${pkgs.system}.xintray
      inputs.po.packages.${pkgs.system}.po
    ];

    networking = {
      hosts = {
        "66.135.2.235" = [ "ns1" ];
        "142.171.43.82" = [ "ns2" ];
        "46.23.94.18" = [ "ns3" ];
        "198.23.149.18" = [ "ns4" ];
      };
    };
  };
}
