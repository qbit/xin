{ config, lib, pkgs, xinlib, ... }:
let
  rage = pkgs.writeScriptBin "rage" (import ../bins/rage.nix { inherit pkgs; });
  rpr = pkgs.writeScriptBin "rpr"
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
  jobs = [{
    name = "promnesia-index";
    script = "${promnesia}/bin/promnesia index";
    startAt = "*:0/5";
    path = [ promnesia hpi ];
  }];
  commonConfigs = {
    fonts.fonts = with pkgs; [ go-font (callPackage ../pkgs/kurinto.nix { }) ];
    sound.enable = true;
    environment.systemPackages = with pkgs; [
      bc
      black
      brave
      drawterm
      go-font
      hpi
      pcsctools
      promnesia
      rage
      rpr
      vlc
      zeal

      (callPackage ../pkgs/tailscale-systray.nix { })
      (callPackage ../pkgs/govulncheck.nix { })
      (callPackage ../configs/helix.nix { })
    ];

    systemd.user.services =
      (lib.listToAttrs (builtins.map xinlib.jobToUserService jobs))
      // promnesiaService;

    programs = {
      firefox = {
        enable = true;
        preferences = {
          # TODO: confirm no issues
          "dom.allow_cut_copy" = false;
          "dom.event.clipboardevents.enabled" = false;
          "media.peerconnection.enabled" = false;

          "beacon.enabled" = false;
          "browser.aboutConfig.showWarning" = false;
          "browser.contentblocking.category" = "strict";
          "browser.newtabpage.activity-stream.feeds.recommendationprovider" =
            false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" =
            false;
          "browser.newtabpage.activity-stream.section.highlights.includeDownloads" =
            false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" =
            false;
          "browser.newtabpage.activity-stream.section.highlights.includeVisited" =
            false;
          "browser.newtabpage.activity-stream.showSearch" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry.structuredIngestion.endpoint" =
            "http://127.0.0.1/null";
          "browser.newtabpage.enabled" = false;
          "browser.newtabpage.pinned" = false;
          "browser.search.suggest.enabled" = false;
          "browser.search.update" = false;
          "browser.topsites.contile.enabled" = false;
          "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          "browser.urlbar.suggest.searches" = false;
          "browser.urlbar.trimURLs" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "devtools.cache.disabled" = true;
          "extensions.pocket.enabled" = false;
          "geo.enabled" = false;
          "geo.provider.network.url" = "";
          "geo.provider.use_geoclue" = false;
          "network.dns.disablePrefetch" = true;
          "network.http.speculative-parallel-limit" = 0;
          "network.IDN_show_punycode" = true;
          "network.predictor.enabled" = false;
          "network.prefetch-next" = false;
          "privacy.resistFingerprinting" = true;
          "security.OCSP.enabled" = false;
          "services.sync.prefs.sync-seen.browser.newtabpage.activity-stream.section.highlights.includePocket" =
            false;
        };
      };
    };
    services = { pcscd.enable = true; };
    security.rtkit.enable = true;
  };
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
    (mkIf config.arcan.enable { services = { xserver.enable = false; }; }
      // commonConfigs)
    (mkIf (config.kde.enable || config.gnome.enable || config.xfce.enable) {
      services = { xserver.enable = true; };
      # TODO: TEMP FIX
      systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart =
        lib.mkForce [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
    } // commonConfigs)
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
