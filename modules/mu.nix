{ config, lib, pkgs, ... }:
let
  cfg = config.muServer;
  mu = "${pkgs.mu}/bin/mu";
  muInitScript = pkgs.writeScriptBin "mu-init-script" ''
    #!${pkgs.runtimeShell}

    set -eu

    while true; do
      if [ ! -d ${cfg.muHome} ]; then
        ${mu} init --muhome="${cfg.muHome}" --maildir="${cfg.mailDir}" --my-address="${cfg.emailAddress}"
      fi
    done
  '';
in {
  options = with lib; {
    muServer = {
      enable = lib.mkEnableOption "Enable mu server";
      muHome = lib.mkOption {
        type = types.path;
        default = "~/.mu";
      };
      mailDir = lib.mkOption {
        type = types.path;
        default = "~/Maildir";
      };
      emailAddress = lib.mkOption {
        type = types.string;
        default = "";
      };
    };
  };

  config = lib.mkIf config.muServer.enable {
    environment.systemPackages = [ muInitScript ];
    systemd.user.services.mu-server = {
      script = "${muInitScript}";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = { Restart = "on-failure"; };
    };
  };
}
