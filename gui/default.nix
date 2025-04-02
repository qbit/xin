{ config
, lib
, pkgs
, xinlib
, inputs
, ...
}:
let
  inherit (builtins) toJSON;
  inherit (inputs.traygent.packages.${pkgs.system}) traygent;
  inherit (inputs.fynado.packages.${pkgs.system}) fynado;
  inherit (inputs.beyt.packages.${pkgs.system}) beyt;
  inherit (inputs.calnow.packages.${pkgs.system}) calnow;
  inherit (inputs.ghostty.packages.${pkgs.system}) ghostty;
  firefox = import ../configs/firefox.nix { inherit pkgs; };
  rage = pkgs.writeScriptBin "rage" (import ../bins/rage.nix { inherit pkgs; });
  rpr =
    pkgs.writeScriptBin "rpr"
      (import ../bins/rpr.nix { inherit (pkgs) hut gh tea; });
  promnesia =
    pkgs.python3Packages.callPackage ../pkgs/promnesia.nix { inherit pkgs; };
  pywebscrapbook =
    pkgs.python3Packages.callPackage ../pkgs/pywebscrapbook.nix { inherit pkgs; };
  hpi = pkgs.python3Packages.callPackage ../pkgs/hpi.nix { inherit pkgs; };
  promnesiaService = {
    promnesia = {
      description = "Service for promnesia.server";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      script = ''
        ${promnesia}/bin/promnesia serve
      '';
    };
  };
  jobs = [
    {
      name = "promnesia-index";
      script = "${promnesia}/bin/promnesia index";
      startAt = "*:0/5";
      path = [ promnesia hpi ];
    }
  ];
  fontSet = with pkgs; [
    go-font
    #(callPackage ../pkgs/kurinto.nix {})
  ];
  traygentCmds = toJSON [
    {
      command_path = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
      #command_path = "${pkgs.ssh-askpass-fullscreen}/bin/ssh-askpass-fullscreen";
      event = "sign";
      msg_format = "Allow access to key %q?";
      exit_code = 0;
    }
    {
      command_path = "${pkgs.kdePackages.kdialog}/bin/kdialog";
      command_args = [ "--title" "traygent" "--passivepopup" "SSH Key Added" "5" ];
      event = "added";
    }
    {
      command_path = "${pkgs.kdePackages.kdialog}/bin/kdialog";
      command_args = [ "--title" "traygent" "--passivepopup" "SSH Key Removed" "5" ];
      event = "removed";
    }
  ];
in
with lib; {
  imports = [
    ../configs/polybar.nix
    ../configs/smug.nix
    ../configs/beet.nix
    ../configs/emacs.nix
    ../configs/konsole.nix
    ../configs/chromium.nix
    ./gnome.nix
    ./kde.nix
    ./xfce.nix
  ];

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
        xserver.enable = true;
        lock-action.enable = true;
        pcscd.enable = true;
      };

      documentation.enable = true;

      # TODO: TEMP FIX
      systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart =
        lib.mkForce [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
      fonts = {
        packages = fontSet;
      };
      environment = {
        etc = {
          "traygent.json" = { text = traygentCmds; };
          "1password/custom_allowed_browsers" = {
            user = "root";
            group = "root";
            mode = "0755";
            text = ''
              ${pkgs.librewolf.meta.mainProgram}
            '';
          };
        };
        sessionVariables = {
          SSH_AUTH_SOCK = "$HOME/.traygent";
        } // (if config.networking.hostName != "stan" then {
          OLLAMA_HOST = "https://ollama.otter-alligator.ts.net";
        } else { });
        systemPackages = with pkgs; (xinlib.filterList [
          bc
          beyt
          black
          calnow
          drawterm-wayland
          exiftool
          fynado
          ghostty
          glamoroustoolkit
          go-font
          govulncheck
          hpi
          keepassxc
          mpv
          pcsctools
          plan9port
          promnesia
          pywebscrapbook
          rage
          recoll
          rpr
          traygent
          trayscale
          vlc
          zeal
        ]);
      };

      programs = {
        ladybird.enable = true;
      } // firefox.programs;

      systemd.user.services =
        (lib.listToAttrs (builtins.map xinlib.jobToUserService jobs))
        // promnesiaService;
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
