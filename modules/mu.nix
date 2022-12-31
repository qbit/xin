{ config, lib, pkgs, ... }:
let
  cfg = config.muInit;
  mu = "${pkgs.mu}/bin/mu";
  muInitScript = pkgs.writeScriptBin "mu-init-script" ''
    #!${pkgs.runtimeShell}

    set -eu

    MU_HOME=~/.cache/mu

    if [ "${cfg.muHome}" != "mudefault" ]; then
      MU_HOME="${cfg.muHome}"
    fi

    while true; do
      if [ ! -d $MU_HOME ]; then
        echo "MU home directory missing: $MU_HOME. Creating it."
        ${mu} init ${
          if cfg.muHome != "mudefault" then "--muhome=${cfg.muHome}" else ""
        } ${if cfg.mailDir != "" then "--maildir=${cfg.mailDir}" else ""} ${
          if cfg.emailAddress != "" then
            "--my-address=${cfg.emailAddress}"
          else
            ""
        }
      fi
      sleep 5;
    done
  '';
in {
  options = with lib; {
    muInit = {
      enable = lib.mkEnableOption "Enable mu server";
      muHome = lib.mkOption {
        type = types.str;
        default = "mudefault";
      };
      mailDir = lib.mkOption {
        type = types.str;
        default = "~/Maildir";
      };
      emailAddress = lib.mkOption {
        type = types.str;
        default = "";
      };
    };
  };

  config = lib.mkIf config.muInit.enable {
    environment.systemPackages = [ muInitScript ];
    systemd.user.services.mu-init = {
      script = "${muInitScript}/bin/mu-init-script";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = { Restart = "on-failure"; };
    };
  };
}
