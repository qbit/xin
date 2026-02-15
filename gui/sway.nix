{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options = {
    sway = {
      enable = mkEnableOption "Enable SWAY.";
    };
  };

  config = mkIf config.sway.enable {
    environment = {
      etc = {
        "sway/config" = {
          mode = "444";
          text = ''
            include /etc/sway/config.d/*

            set $mod Mod1

            set $left left
            set $down down
            set $up up
            set $right right
            set $menu pkill -x wofi || wofi --show drun --prompt=Search --no-actions --insensitive --allow-images --width="66%" --height="66%" --style="$HOME/.config/wofi.css"

            input type:keyboard {
              xkb_layout ${config.services.xserver.xkb.layout}
              xkb_variant ${config.services.xserver.xkb.variant}
              xkb_options ${config.services.xserver.xkb.options}
            }

            input type:touchpad {
              natural_scroll enabled
              tap enabled
            }

            set $term ghostty

            bindsym $mod+r exec $menu
            bindsym $mod+Return exec $term
            bindsym $mod+Shift+l exec swaylock
            bindsym $mod+Escape kill
            floating_modifier $mod normal
            bindsym $mod+Shift+c reload
            bindsym $mod+Shift+e exec swaynag -t warning -m 'Are you sure you want to exit sway?' -b 'Yes' 'swaymsg exit'

            exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
            exec nm-applet
            exec kwalletd6
            #exec rm -f "$HOME/.fynado.socket"; fynado

            exec swayidle -w \
              timeout 300 'swaylock -f -c 000000' \
              timeout 600 'brightnessctl --save; brightnessctl set 0' \
              resume 'brightnessctl --restore' \
              before-sleep 'swaylock -f -c 000000'

            bindsym $mod+1 workspace 1
            bindsym $mod+2 workspace 2
            bindsym $mod+3 workspace 3
            bindsym $mod+4 workspace 4
            bindsym $mod+5 workspace 5
            bindsym $mod+6 workspace 6
            bindsym $mod+7 workspace 7
            bindsym $mod+8 workspace 8
            bindsym $mod+9 workspace 9
            bindsym $mod+0 workspace 10

            bindsym $mod+Shift+1 move container to workspace 1
            bindsym $mod+Shift+2 move container to workspace 2
            bindsym $mod+Shift+3 move container to workspace 3
            bindsym $mod+Shift+4 move container to workspace 4
            bindsym $mod+Shift+5 move container to workspace 5
            bindsym $mod+Shift+6 move container to workspace 6
            bindsym $mod+Shift+7 move container to workspace 7
            bindsym $mod+Shift+8 move container to workspace 8
            bindsym $mod+Shift+9 move container to workspace 9
            bindsym $mod+Shift+0 move container to workspace 10

            bindsym $mod+h splith
            bindsym $mod+v splitv
            bindsym $mod+s layout stacking
            bindsym $mod+w layout tabbed
            bindsym $mod+e layout toggle split

            bindsym $mod+Shift+minus move scratchpad
            bindsym $mod+minus scratchpad show

            bindsym --locked XF86AudioPlay exec playerctl play-pause
            bindsym --locked XF86AudioNext exec playerctl next
            bindsym --locked XF86AudioPrev exec playerctl previous

            bindsym $mod+space floating toggle
            bindsym $mod+Shift+space focus mode_toggle

            for_window [window_role = "pop-up"] floating enable
            for_window [window_role = "bubble"] floating enable
            for_window [window_role = "dialog"] floating enable
            for_window [window_type = "dialog"] floating enable
            for_window [window_role = "task_dialog"] floating enable
            for_window [window_type = "menu"] floating enable
            for_window [app_id = "floating"] floating enable

          '';
        };
      };
      systemPackages = with pkgs; [
        wdisplays
        wofi
        xdg-desktop-portal
        (signal-desktop.overrideAttrs (oldAttrs: {
          postFixup = (oldAttrs.postFixup or "") + ''
            wrapProgram $out/bin/signal-desktop \
              --add-flags "--password-store=kwallet6" \
              --add-flags "--enable-features=UseOzonePlatform" \
              --add-flags "--ozone-platform=wayland"
          '';
        }))
      ];
    };

    programs = {
      uwsm.enable = true;
      light.enable = true;
      waybar.enable = true;
      sway = {
        enable = true;
        xwayland.enable = true;
        wrapperFeatures.gtk = true;
      };
    };

    users.users."${config.defaultUserName}".extraGroups = [ "video" ];

    security = {
      pam = {
        services = {
          ${config.defaultUserName} = {
            kwallet = {
              enable = true;
              package = pkgs.kdePackages.kwallet-pam;
              forceRun = true;
            };
          };
        };
      };
    };

    services = {
      displayManager.sddm.enable = true;
    };
  };
}
