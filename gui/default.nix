{ config, lib, pkgs, xinlib, ... }:
let
  rage = pkgs.writeScriptBin "rage" (import ../bins/rage.nix { inherit pkgs; });
  rpr = pkgs.writeScriptBin "rpr" (import ../bins/rpr.nix {
    inherit (pkgs) _1password;
    inherit (pkgs) gh;
    inherit (pkgs) tea;
  });
  promnesia =
    pkgs.python3Packages.callPackage ../pkgs/promnesia.nix { inherit pkgs; };
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
  jobs = [{
    name = "promnesia-index";
    script = "${promnesia}/bin/promnesia index";
    startAt = "*:0/5";
    path = [ promnesia hpi ];
  }];
in with lib; {
  imports = [ ./gnome.nix ./kde.nix ./xfce.nix ./arcan.nix ];

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
    (mkIf config.arcan.enable {
      sound.enable = true;
      services = { xserver.enable = false; };
      environment.systemPackages = with pkgs; [ brave go-font vlc pcsctools ];
    })
    (mkIf (config.kde.enable || config.gnome.enable || config.xfce.enable) {

      services = {
        xserver.enable = true;
        pcscd.enable = true;
      };

      fonts.fonts = with pkgs; [
        go-font
        (callPackage ../pkgs/kurinto.nix { })
      ];

      # TODO: TEMP FIX
      systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart =
        lib.mkForce [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];

      sound.enable = true;
      security.rtkit.enable = true;

      # https://github.com/NixOS/nixpkgs/pull/213593
      nixpkgs.config.permittedInsecurePackages = [
        "electron-18.1.0" # obsidian
      ];

      systemd.user.services =
        (lib.listToAttrs (builtins.map xinlib.jobToService jobs))
        // promnesiaService;

      environment.systemPackages = with pkgs; [
        brave
        vlc
        pcsctools
        rage
        rpr
        (callPackage ../pkgs/tailscale-systray.nix { })
        promnesia
        black
      ];

      programs = {
        firejail = {
          enable = true;
          wrappedBinaries = {
            #firefox = {
            #  executable = "${lib.getBin pkgs.firefox}/bin/firefox";
            #  profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
            #};
            #brave = {
            #  executable = "${lib.getBin pkgs.brave}/bin/brave";
            #  profile = "${pkgs.firejail}/etc/firejail/brave.profile";
            #};
          };
        };
      };

    })
    (mkIf config.pulse.enable { hardware.pulseaudio = { enable = true; }; })
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
