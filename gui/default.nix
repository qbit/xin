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
    (mkIf (config.kde.enable || config.gnome.enable || config.xfce.enable) {
      services = {
        xserver.enable = true;
        pcscd.enable = true;
      };

      # TODO: TEMP FIX
      systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart =
        lib.mkForce [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
      fonts.fonts = with pkgs; [
        go-font
        (callPackage ../pkgs/kurinto.nix { })
      ];
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

        firefox

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
          policies = {
            ExtensionSettings = {
              "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
                "installation_mode" = "force_installed";
                "install_url" =
                  "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
              };
              "custom-new-tab-page@mint.as" = {
                "installation_mode" = "force_installed";
                "install_url" =
                  "https://addons.mozilla.org/firefox/downloads/latest/custom-new-tab-page/latest.xpi";
              };
              "simple-tab-groups@drive4ik" = {
                "installation_mode" = "force_installed";
                "install_url" =
                  "https://addons.mozilla.org/firefox/downloads/latest/simple-tab-groups/latest.xpi";
              };
              "{07c6b8e1-94f7-4bbf-8e91-26c0a8992ab5}" = {
                "installation_mode" = "force_installed";
                "install_url" =
                  "https://addons.mozilla.org/firefox/downloads/latest/promnesia/latest.xpi";
              };
              "7esoorv3@alefvanoon.anonaddy.me" = {
                "installation_mode" = "force_installed";
                "install_url" =
                  "https://addons.mozilla.org/firefox/downloads/latest/libredirect/latest.xpi";
              };
              "{b86e4813-687a-43e6-ab65-0bde4ab75758}" = {
                "installation_mode" = "force_installed";
                "install_url" =
                  "https://addons.mozilla.org/firefox/downloads/latest/localcdn-fork-of-decentraleyes/latest.xpi";
              };
              "uBlock0@raymondhill.net" = {
                "installation_mode" = "force_installed";
                "install_url" =
                  "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              };
            };
          };
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
            "browser.newtabpage.activity-stream.feeds.section.topstories" =
              false;
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
