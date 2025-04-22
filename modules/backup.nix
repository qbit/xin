{ lib, inputs, config, utils, pkgs, ... }:
with lib;
let
  inherit (utils.systemdUtils.unitOptions) unitOption;
  cfg = config.services.backups;
  enabledBackups = filterAttrs (_: conf: conf.enable) cfg;
in
{
  options = {
    services.backups = mkOption {
      description = "Backup configurations, wrapped to allow for notifications of failed backups.";
      default = { };
      type = with types; attrsOf (submodule ({ name, ... }: {
        options = {
          enable = mkEnableOption "Enable backup for ${name}";

          passwordFile = mkOption {
            type = path;
            description = "Path to file containing password.";
          };

          repository = mkOption {
            type = nullOr str;
            default = null;
            description = "optional path to repository (can also be specified in the repositoryFile.";
          };

          repositoryFile = mkOption {
            type = nullOr path;
            default = null;
            description = "Path to repository file.";
          };

          environmentFile = mkOption {
            type = nullOr str;
            default = null;
            description = "path to environment file";
          };

          paths = mkOption {
            type = listOf str;
            description = "List of paths to backup.";
            default = [ ];
          };

          pruneOpts = mkOption {
            type = listOf str;
            description = "Options for 'restic forget'.";
            default = [ "--keep-hourly 12" "--keep-daily 7" "--keep-weekly 5" "--keep-yearly 4" ];
          };

          timerConfig = mkOption {
            type = nullOr (attrsOf unitOption);
            description = "systemd.timer(5) settings for when to do the backup.";
            default = {
              OnCalendar = "daily";
              Persistent = true;
            };
          };
        };
      }));
    };
  };
  config = mkIf (enabledBackups != { }) {
    services.restic.backups =

      mapAttrs'
        (name: conf: nameValuePair
          name
          {
            initialize = true;
            inherit (conf) passwordFile repository repositoryFile paths pruneOpts timerConfig environmentFile;
          })
        enabledBackups;

    systemd.services =
      let
        powerCheck = pkgs.writeShellScriptBin "power-check" ''
          if ${pkgs.pmutils}/bin/on_ac_power; then
             echo "ON AC, continuing backup"
          else
            echo "NOT on AC, skipping backup"
            exit 1
          fi
        '';
      in
      mkMerge [
        (mapAttrs'
          (name: _: nameValuePair
            "restic-backups-${name}-failed"
            {
              enable = true;
              description = "Notification service for ${name}";
              serviceConfig = {
                Type = "oneshot";
              };
              script = ''
                . ${config.sops.secrets.po_env.path}
            
                PO=${inputs.po.packages.${pkgs.system}.po}/bin/po
                if ${pkgs.pmutils}/bin/on_ac_power; then
                  $PO -title "restic-${name} backup failed!" -body "Please check the ${name} backup on ${config.networking.hostName}."
                fi
              '';

            })
          enabledBackups)
        (mapAttrs'
          (name: _: nameValuePair
            "restic-backups-${name}"
            {
              serviceConfig =

                {
                  ExecStartPre = "${powerCheck}/bin/power-check";
                };
              unitConfig = {
                OnFailure = "restic-backups-${name}-failed.service";
              };
            })
          enabledBackups)
      ];
  };
}
