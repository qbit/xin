{ config
, lib
, pkgs
, xinlib
, isUnstable
, ...
}:
let
  firefox = import ../configs/firefox.nix { inherit pkgs; };
  rage = pkgs.writeScriptBin "rage" (import ../bins/rage.nix { inherit pkgs; });
  rpr =
    pkgs.writeScriptBin "rpr"
      (import ../bins/rpr.nix { inherit (pkgs) hut gh tea; });
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
in
with lib; {
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
    (mkIf (config.kde.enable || config.gnome.enable || config.xfce.enable) {
      services = {
        xserver.enable = true;
        pcscd.enable = true;
      };

      documentation.enable = true;

      # TODO: TEMP FIX
      systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart =
        lib.mkForce [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
      fonts = if isUnstable then { packages = fontSet; } else { fonts = fontSet; };
      sound.enable = true;
      environment.systemPackages = with pkgs; (xinlib.filterList [
        arcanPackages.all-wrapped
        bc
        black
        drawterm
        exiftool
        go-font
        govulncheck
        hpi
        pcsctools
        promnesia
        rage
        rpr
        vlc
        zeal

        (callPackage ../configs/helix.nix { })
      ]);

      programs = { } // firefox.programs;

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
