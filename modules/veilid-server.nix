{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs;
let
  cfg = config.services.veilid-server;
in
{
  options = with lib; {
    services.veilid-server = {
      enable = mkEnableOption "Enable velid-server";
      user = mkOption {
        type =
          with types;
          oneOf [
            str
            int
          ];
        default = "veilid";
        description = "The user veilid-server will run as.";
      };

      group = mkOption {
        type =
          with types;
          oneOf [
            str
            int
          ];
        default = "veilid";
        description = "The group veilid-server will run with.";
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/veilid";
        description = "Path for veilid-server state directory.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.veilid;
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "enable veilid-server in the firewall";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      inherit (cfg) group;
      description = "veilid-server user";
      isSystemUser = true;
      home = cfg.dataDir;
      createHome = true;
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ 5150 ];
      allowedUDPPorts = [ 5150 ];
    };

    systemd.services.veilid-server = {
      enable = true;
      description = "veilid-server";
      wants = [ "network-online.target" ];

      environment = {
        HOME = cfg.dataDir;
      };

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;

        RuntimeDirectory = "veilid";
        StateDirectory = "veilid";
        StateDirectoryMode = "0700";
        CacheDirectory = "veilid";

        ExecStart = "${cfg.package}/bin/veilid-server";
      };
    };
  };
}
