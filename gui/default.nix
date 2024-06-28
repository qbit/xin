{ config
, lib
, pkgs
, xinlib
, isUnstable
, inputs
, ...
}:
let
  inherit (builtins) toJSON;
  inherit (inputs.traygent.packages.${pkgs.system}) traygent;
  inherit (inputs.beyt.packages.${pkgs.system}) beyt;
  firefox = import ../configs/firefox.nix { inherit pkgs; };
  rage = pkgs.writeScriptBin "rage" (import ../bins/rage.nix { inherit pkgs; });
  myEmacs = pkgs.callPackage ../configs/emacs.nix { inherit isUnstable; };
  rpr =
    pkgs.writeScriptBin "rpr"
      (import ../bins/rpr.nix { inherit (pkgs) hut gh tea; });
  jobs = [
  ];
  fontSet = with pkgs; [
    go-font
    #(callPackage ../pkgs/kurinto.nix {})
  ];
  traygentCmds = toJSON [
    {
      command_path = "${pkgs.ksshaskpass}/bin/ksshaskpass";
      #command_path = "${pkgs.ssh-askpass-fullscreen}/bin/ssh-askpass-fullscreen";
      event = "sign";
      msg_format = "Allow access to key %q?";
      exit_code = 0;
    }
    {
      command_path = "${pkgs.kdialog}/bin/kdialog";
      command_args = [ "--title" "traygent" "--passivepopup" "SSH Key Added" "5" ];
      event = "added";
    }
    {
      command_path = "${pkgs.kdialog}/bin/kdialog";
      command_args = [ "--title" "traygent" "--passivepopup" "SSH Key Removed" "5" ];
      event = "removed";
    }
  ];
in
with lib; {
  imports = [ ./gnome.nix ./kde.nix ./xfce.nix ];

  options = {
    pulse = {
      enable = mkOption {
        description = "Enable PulseAudio";
        default = false;
        example = true;
        type = types.bool;
      };
    };
    pipewire = {
      enable = mkOption {
        description = "Enable PipeWire";
        default = true;
        example = true;
        type = types.bool;
      };
    };
  };

  config = mkMerge [
    (mkIf (config.kde.enable || config.gnome.enable || config.xfce.enable) {
      services = {
        lock-action.enable = true;
        pcscd.enable = true;
      };

      documentation.enable = true;

      # TODO: TEMP FIX
      systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart =
        lib.mkForce [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
      fonts = if isUnstable then { packages = fontSet; } else { fonts = fontSet; };
      sound.enable = true;
      environment = {
        etc."traygent.json" = { text = traygentCmds; };
        sessionVariables = {
          SSH_AUTH_SOCK = "$HOME/.traygent";
          OLLAMA_HOST = "https://ollama.otter-alligator.ts.net";
        };
        systemPackages = with pkgs; (xinlib.filterList [
          alacritty
          bc
          beyt
          black
          drawterm-wayland
          exiftool
          go-font
          govulncheck
          keepassxc
          pcsctools
          plan9port
          rage
          rpr
          traygent
          vlc
          zeal

          myEmacs
          (callPackage ../configs/helix.nix { })
        ]);
      };

      programs = { } // firefox.programs;

      systemd.user.services =
        lib.listToAttrs (builtins.map xinlib.jobToUserService jobs);
      security.rtkit.enable = true;
    })
    (mkIf config.pipewire.enable {
      services.pipewire = {
        enable = true;
        pulse.enable = true;
        jack.enable = true;
        alsa.enable = true;
      };
    })
  ];
}
