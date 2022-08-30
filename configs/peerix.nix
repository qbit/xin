{ config, lib, ... }:
with lib; {
  options = {
    tsPeerix = {
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

  config = mkIf config.tsPeerix.enable {
    users.groups.peerix = {
      name = "peerix";
    };
    users.users.peerix = {
      name = "peerix";
      group = "peerix";
      isSystemUser = true;
    };
    services = {
      peerix = {
        enable = true;
        openFirewall = false;
        user = "peerix";
        privateKeyFile = "${config.tsPeerix.privateKeyFile}";
        publicKeyFile = ./peerix.pubs;
      };
    };
    networking.firewall.interfaces = {
      "tailscale0" = {
        allowedUDPPorts = [ 12304 ];
        allowedTCPPorts = [ 12304 ];
      };
    };
  };
}
