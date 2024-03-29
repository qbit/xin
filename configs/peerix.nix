{ config
, lib
, pkgs
, ...
}:
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
      interfaces = mkOption {
        description = "Interfaces to allow peerix to listen on.";
        type = types.listOf types.str;
        default = [ "tailscale0" ];
      };
    };
  };

  config = mkIf config.tsPeerix.enable {
    users.groups.peerix = { name = "peerix"; };
    users.users.peerix = {
      name = "peerix";
      group = "peerix";
      isSystemUser = true;
    };

    nix.settings.allowed-users = [ "peerix" ];

    services = {
      zerotierone = {
        enable = true;
        joinNetworks = [ "db64858fedd3b256" ];
      };

      peerix = {
        enable = true;
        openFirewall = false;
        user = "peerix";
        group = "peerix";
        privateKeyFile = "${config.tsPeerix.privateKeyFile}";
        publicKeyFile = ./peerix.pubs;
      };
    };

    environment.systemPackages = [ pkgs.zerotierone ];

    networking.firewall.interfaces = listToAttrs (flatten (map
      (i: {
        name = i;
        value = {
          allowedUDPPorts = [ 12304 ];
          allowedTCPPorts = [ 12304 ];
        };
      })
      config.tsPeerix.interfaces));
  };
}
