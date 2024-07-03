{ pkgs, lib, config, ... }:
let
  cfg = config.services.lock-action;
  dbus-monitor = "${pkgs.dbus}/bin/dbus-monitor";
  awk = "${pkgs.gawk}/bin/awk";
  ssh-add = "${pkgs.openssh}/bin/ssh-add";
  action-script = pkgs.writeScript "action-script" ''
    export DBUS_SESSION_BUS_ADDRESS="$(systemctl --user show-environment | ${awk} -F= '/^DBUS_SESSION_BUS_ADDRESS/ {print $(NF-1) "=" $NF}')"
    export SSH_AUTH_SOCK="$(systemctl --user show-environment | ${awk} -F= '/^SSH_AUTH_SOCK/ {print $NF}')"

    echo $DBUS_SESSION_BUS_ADDRESS
    echo $SSH_AUTH_SOCK

    ${dbus-monitor} --session "type='signal',interface='org.freedesktop.ScreenSaver'" | \
    while read x; do
      case "$x" in
        *"boolean true"*)
          echo "Screen Locked";
          ${ssh-add} -D
          /run/wrappers/bin/sudo -K
      esac
    done

  '';
in
{
  options = {
    services.lock-action = {
      enable = lib.mkEnableOption "Enable lock actions";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.user.services.lock-action = {
      enable = true;
      script = ''
        ${action-script}
      '';

      environment = {
        DBUS_SESSION_BUS_ADDRESS = "fake";
        SSH_AUTH_SOCK = "fake";
      };

      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
    };
  };
}
