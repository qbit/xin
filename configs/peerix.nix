{ config, lib, ... }:
with lib; {
  options = {
    peerix = {
      enable = mkOption {
        description = "Enable peerix";
        default = false;
        example = true;
        type = lib.types.bool;
      };
      privateKeyFile = mkOption {
        description = "Private key file for signing";
        default = "";
        example = "./private_key";
        type = lib.types.path;
      };
    };
  };

  config = mkIf config.peerix.enable {
    services = {
      peerix = {
        enable = true;
        openFirewall = false; # UDP/12304
        privateKeyFile = "${config.peerix.privateKeyFile}";
        publicKeyFile = ../../configs/peerix.pubs;
      };
    };
    networking.firewall.interfaces = {
      "tailscale0" = {
        allowedUDPPorts = 12304;
      };
    };
  };
}
