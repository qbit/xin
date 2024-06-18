{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.services.xinCA;
in
with lib; {
  options = {
    services.xinCA = {
      enable = mkEnableOption "Configure host as a xin certificate authority.";

      user = mkOption {
        type = types.str;
        default = "step-ca";
        description = ''
          User who will own the CA key material.
        '';
      };
    };
  };

  imports = [ ];
  config = mkIf cfg.enable {
    sops.secrets = {
      ca_password = {
        mode = "400";
        owner = cfg.user;
        sopsFile = config.xin-secrets.cert_authority;
      };
      "defaults.json" = {
        mode = "400";
        owner = cfg.user;
        path = "/var/lib/step-ca/config/defaults.json";
        sopsFile = config.xin-secrets.cert_authority;
      };
      "intermediate_ca.crt" = {
        mode = "444";
        owner = cfg.user;
        path = "/var/lib/step-ca/certs/intermediate_ca.crt";
        sopsFile = config.xin-secrets.cert_authority;
      };
      "intermediate_ca_key" = {
        mode = "400";
        owner = cfg.user;
        path = "/var/lib/step-ca/secrets/intermediate_ca_key";
        sopsFile = config.xin-secrets.cert_authority;
      };
      "root_ca.crt" = {
        mode = "444";
        owner = cfg.user;
        path = "/var/lib/step-ca/certs/root_ca.crt";
        sopsFile = config.xin-secrets.cert_authority;
      };
      "root_ca_key" = {
        mode = "400";
        owner = cfg.user;
        path = "/var/lib/step-ca/secrets/root_ca_key";
        sopsFile = config.xin-secrets.cert_authority;
      };
      "jwk_encryptedKey" = {
        mode = "400";
        owner = cfg.user;
        path = "/var/lib/step-ca/secrets/jwk_encryptedKey";
        sopsFile = config.xin-secrets.cert_authority;
      };
    };

    networking.hosts = { "127.0.0.1" = [ "ca.bolddaemon.com" ]; };

    environment.sessionVariables = { STEPPATH = "/var/lib/step-ca"; };
    environment.systemPackages = with pkgs; [
      #step-cli
      step-kms-plugin
      opensc
      libressl
    ];

    services.step-ca = {
      enable = true;
      intermediatePasswordFile = "${config.sops.secrets.ca_password.path}";
      address = "127.0.0.1";
      port = 443;
      settings = {
        root = config.sops.secrets."root_ca.crt".path;
        crt = config.sops.secrets."intermediate_ca.crt".path;
        key = config.sops.secrets.intermediate_ca_key.path;
        dnsNames = [ "ca.bolddaemon.com" ];
        logger = { format = "text"; };
        db = {
          type = "badgerv2";
          dataSource = "/var/lib/step-ca/db";
          badgerFileLoadingMode = "";
        };
        authority = {
          provisioners = [
            {
              type = "SSHPOP";
              name = "sshpop";
              claims = { enableSSHCA = true; };
            }
          ];
        };

        tls = {
          cipherSuites = [
            "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
            "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
          ];
          minVersion = 1.2;
          maxVersion = 1.3;
          renegotiation = false;
        };
      };
    };
  };
}
