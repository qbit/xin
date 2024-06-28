{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.services.ts-reverse-proxy;
  enabledServers = filterAttrs (_: conf: conf.enable) cfg.servers;
in
{
  options = {
    services.ts-reverse-proxy = {
      package = mkPackageOption pkgs "ts-reverse-proxy" { };

      servers = mkOption {
        description = "Configuration of multiple `ts-reverse-proxy` instalces.";
        default = { };

        type = with types; attrsOf (submodule ({ name, ... }: {
          options = {
            enable = lib.mkEnableOption "Enable ts-reverse-proxy for ${name}";
            reversePort = mkOption {
              type = types.int;
              default = 5000;
              description = ''
                Port to forward connections to.
              '';
            };

            reverseIP = mkOption {
              type = types.str;
              default = "127.0.0.1";
              description = ''
                IP to forward connections to.
              '';
            };

            reverseName = mkOption {
              type = types.str;
              default = name;
              description = ''
                Name used in for the front facing http server (will be a tailscale name).
              '';
            };

            hostHeader = mkOption {
              type = types.str;
              default = "";
              description = ''
                Manually set the Host header
              '';
            };

            user = mkOption {
              type = with types; oneOf [ str int ];
              default = name;
              description = ''
                The user the service will use.
              '';
            };

            group = mkOption {
              type = with types; oneOf [ str int ];
              default = name;
              description = ''
                The group the service will use.
              '';
            };

            dataDir = mkOption {
              type = types.path;
              default = "/var/lib/${name}";
              description = "Path ts-reverse-proxy home directory";
            };

            envFile = mkOption {
              type = types.path;
              default = "/run/secrets/ts_proxy_env-${name}";
              description = ''
                Path to a file containing the ts-reverse-proxy token information
              '';
            };
          };
        }));
      };
    };
  };

  config = mkIf (enabledServers != { }) {
    environment.systemPackages = [ cfg.package ];

    users.groups = mapAttrs'
      (name: _: nameValuePair name { })
      enabledServers;
    users.users = mapAttrs'
      (name: conf: nameValuePair name {
        description = "System user for ts-reverse-proxy instance ${name}";
        isSystemUser = true;
        group = name;
        home = "${conf.dataDir}";
        createHome = true;
      })
      enabledServers;

    systemd.services = mapAttrs'
      (name: conf: nameValuePair name {
        description = "ts-reverse-proxy instance ${name}";
        enable = true;
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        environment = { HOME = "${conf.dataDir}"; };

        serviceConfig = {
          User = conf.user;
          Group = conf.group;

          ExecStart = "${cfg.package}/bin/ts-reverse-proxy ${lib.optionalString (conf.hostHeader != "") "-host-header '${conf.hostHeader}'"} -name ${conf.reverseName} -port ${
          toString conf.reversePort
        } -ip ${conf.reverseIP}";
          #EnvironmentFile = conf.envFile;
        };
      })
      enabledServers;
  };
}
