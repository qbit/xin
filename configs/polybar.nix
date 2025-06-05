{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  barBase = {
    background = "\${colors.background}";
    foreground = "\${colors.foreground}";

    border-color = "#DEDeff";
    border-size = "2pt";

    width = "100%";
    height = "24pt";

    enable-ipc = true;

    font-0 = "Go Mono;3";

    line-size = "3pt";
    module-margin = 1;
    padding = 2;
    radius = 15;
    separator = "|";

    modules-left = "xworkspaces";
    modules-right = "wifi ethernet memory cpu battery date";
  };
  settings = {
    colors = {
      background = "#ffffea";
      background-alt = "#373B41";
      foreground = "#000000";
      primary = "#F0C674";
      secondary = "#8ABEB7";
      alert = "#A54242";
      disabled = "#707880";
    };

    "module/cpu" = {
      type = "internal/cpu";
      interval = 2;
      format-prefix = "CPU: ";
      label = "%percentage:2%%";
    };

    "module/date" = {
      type = "internal/date";
      interval = 1;

      date = "%H:%M";
      date-alt = "%Y-%m-%d %H:%M:%S";

      label = "%date%";
    };

    "module/memory" = {
      type = "internal/memory";
      interval = 2;
      format-prefix = "RAM: ";
      label = "%percentage_used:2%%";
    };

    "module/xworkspaces" = {
      type = "internal/xworkspaces";
    };

    "module/xwindow" = {
      type = "internal/xwindow";
    };

    "module/systray" = {
      type = "internal/tray";
    };

    "module/battery" = {
      type = "internal/battery";
      full-at = 99;
      low-at = 5;

      # $ ls -1 /sys/class/power_supply/
      battery = "BAT1";
      adapter = "ACAD";

      poll-interval = 5;

      time-format = "%H:%M";

      label-charging = "+%percentage%%";
      label-discharging = "-%percentage%%";
      label-low = "BATTERY LOW";
    };

    "module/wifi" = {
      type = "internal/network";
      interface-type = "wireless";

      accumulate-stats = true;

      label-connected = "%essid% %netspeed%";
    };

    "module/ethernet" = {
      type = "internal/network";
      interface-type = "wired";

      accumulate-stats = true;

      label-connected = "%netspeed%";
    };

    "bar/europa" = barBase // { };
    "bar/clunk" = barBase // { };
  };
  settingsFormat = pkgs.formats.ini { };
  settingsFile = settingsFormat.generate "polybar-config.ini" settings;
in
{
  config = mkIf (config.kde.enable || config.gnome.enable || config.xfce.enable) {
    environment = {
      systemPackages = [ pkgs.polybar ];
      etc = {
        "xdg/polybar/config.ini".text = builtins.readFile settingsFile;
      };
    };
    fonts = {
      packages = [ pkgs.go-font ];
    };
  };
}
