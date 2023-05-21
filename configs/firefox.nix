{ ... }:

{
  programs = {
    firefox = {
      enable = true;
      #package = pkgs.firefox-esr;
      policies = {
        DisableFirefoxStudies = true;
        DisableFormHistory = true;
        DisablePocket = true;
        DisableTelemetry = true;
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
      };
      preferences = {
        # TODO: confirm no issues
        "dom.allow_cut_copy" = false;
        "dom.event.clipboardevents.enabled" = false;
        "media.peerconnection.enabled" = false;

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
        "security.OCSP.enabled" = false;
        "security.ssl.errorReporting.enabled" = false;

        # Not yet working:
        # https://github.com/mozilla/policy-templates/blob/master/README.md#preferences
        "beacon.enabled" = false;
        "privacy.resistFingerprinting" = true;
        "services.sync.prefs.sync-seen.browser.newtabpage.activity-stream.section.highlights.includePocket" =
          false;
      };
    };
  };
}
