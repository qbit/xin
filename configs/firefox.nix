{
  lib,
  pkgs,
  config,
  ...
}:
let
  defaultBrowser = pkgs.librewolf;
in
{
  config = lib.mkIf (config.kde.enable || config.gnome.enable || config.xfce.enable) {
    environment = {
      etc = {
        "1password/custom_allowed_browsers" = {
          user = "root";
          group = "root";
          mode = "0755";
          text = ''
            ${defaultBrowser.meta.mainProgram}
          '';
        };
      };
    };
    programs = {
      firefox = {
        enable = true;
        package = defaultBrowser;
        policies = {
          DisableFirefoxStudies = true;
          DisableFormHistory = true;
          DisablePocket = true;
          DisableTelemetry = true;
          EnableTrackingProtection = {
            Fingerprinting = true;
            Cryptomining = true;
            EmailTracking = true;
          };
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
              "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/simple-tab-groups/latest.xpi";
            };
            "{07c6b8e1-94f7-4bbf-8e91-26c0a8992ab5}" = {
              "installation_mode" = "force_installed";
              "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/promnesia/latest.xpi";
            };
            "7esoorv3@alefvanoon.anonaddy.me" = {
              "installation_mode" = "force_installed";
              "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/libredirect/latest.xpi";
            };
            "uBlock0@raymondhill.net" = {
              "installation_mode" = "force_installed";
              "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            };
            "@testpilot-containers" = {
              "installation_mode" = "force_installed";
              "install_url" =
                "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
            };
            "jid1-MnnxcxisBPnSXQ@jetpack" = {
              "installation_mode" = "force_installed";
              "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            };
            "floccus@handmadeideas.org" = {
              "installation_mode" = "normal_installed";
              "install_url" = "https://addons.mozilla.org/firefox/downloads/latest/floccus/latest.xpi";
            };
          };
          FirefoxHome = {
            Search = false;
            TopSites = false;
            SponsoredTopSites = false;
            Highlights = false;
            Pocket = false;
            SponsoredPocket = false;
            Snippets = false;
            Locked = true;
          };
          NetworkPrediction = true;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
          PasswordManagerEnabled = false;
          SearchBar = "unified";
          SearchEngines = {
            Add = [
              {
                Name = "Kagi";
                URLTemplate = "https://kagi.com/search?q={searchTerms}";
                Method = "GET";
                Alias = "k";
              }
              {
                Name = "OpenBSD.app";
                URLTemplate = "https://openbsd.app/?search={searchTerms}";
                Method = "GET";
              }
            ];
            Default = "Kagi";
            Remove = [
              "Google"
              "Amazon.com"
              "Bing"
              "eBay"
              "Wikipedia (en)"
              "DuckDuckGo"
            ];
          };
          SearchSuggestEnabled = false;
          UserMessaging = {
            WhatsNew = false;
            ExtensionRecommendations = false;
            FeatureRecommendations = false;
            UrlbarInterventions = false;
            SkipOnboarding = false;
            MoreFromMozilla = false;
          };
          PDFjs = {
            Enabled = false;
          };
        };
        # NOTE: https://mozilla.github.io/policy-templates/
        # Items can be found here ^
        preferences = {
          "dom.event.clipboardevents.enabled" = false;
          "dom.serviceWorkers.enabled" = false;

          # This causes some issues with a few things I use
          #"media.peerconnection.enabled" = false;

          "browser.aboutConfig.showWarning" = false;
          "browser.contentblocking.category" = "strict";
          "browser.newtabpage.activity-stream.feeds.recommendationprovider" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
          "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
          "browser.newtabpage.activity-stream.showSearch" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry.structuredIngestion.endpoint" =
            "http://127.0.0.1/null";
          "browser.newtabpage.enabled" = false;
          "browser.newtabpage.pinned" = false;
          "browser.promo.focus.enabled" = false;
          "browser.promo.pin.enabled" = false;
          "browser.search.suggest.enabled" = false;
          "browser.search.update" = false;
          "browser.topsites.contile.enabled" = false;
          "browser.urlbar.suggest.calculator" = true;
          "browser.urlbar.suggest.pocket" = false;
          "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          "browser.urlbar.suggest.searches" = false;
          "browser.urlbar.suggest.topsites" = false;
          "browser.urlbar.suggest.trending" = false;
          "browser.urlbar.suggest.yelp" = false;
          "browser.urlbar.trimURLs" = false;
          "browser.vpn_promo.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "devtools.cache.disabled" = true;
          "dom.block_download_insecure" = false;
          "dom.private-attribution.submission.enabled" = false;
          "extensions.pocket.enabled" = false;
          "extensions.screenshots.disabled" = true;
          "geo.enabled" = false;
          "geo.provider.network.url" = "";
          "geo.provider.use_geoclue" = false;
          "network.dns.disablePrefetch" = true;
          "network.http.speculative-parallel-limit" = 0;
          "network.IDN_show_punycode" = true;
          "network.predictor.enabled" = false;
          "network.prefetch-next" = false;
          "security.OCSP.enabled" = 0;
          "security.ssl.errorReporting.enabled" = false;

          # Not yet working:
          "beacon.enabled" = false;
        };
      };
    };
  };
}
