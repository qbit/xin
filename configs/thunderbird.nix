{ ... }:
{
  programs = {
    thunderbird = {
      enable = true;
      policies = {
        Cookies = {
          Allow = [ "https://app.fastmail.com" ];
          AllowSession = [ "https://app.fastmail.com/" ];
          Block = [ "*" ];
          Default = true;
          AcceptThirdParty = "never";
          ExpireAtSessionEnd = false;
          RejectTracker = true;
          Locked = true;
        };
        DisableTelemetry = true;
        ExtensionSettings = {
          "*" = {
            blocked_install_message = "Only install extensions via nix.";
            install_sources = [
              "about:addons"
              "https://addons.thunderbird.net/"
            ];
            installation_mode = "blocked";
            allowed_types = [ "extension" ];
          };
          "uBlock0@raymondhill.net" = {
            "installation_mode" = "force_installed";
            "install_url" =
              "https://addons.thunderbird.net/thunderbird/downloads/latest/ublock-origin/latest.xpi";
          };
          "{532269cf-a10e-4396-8613-b5d9a9a516d4}" = {
            "installation_mode" = "forced_installed";
            "install_url" =
              "https://addons.thunderbird.net/thunderbird/downloads/latest/allow-html-temp/latest.xpi";
          };
        };
        NetworkPrediction = true;
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
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
        PDFjs = {
          Enabled = false;
        };
      };
      # NOTE: https://github.com/thunderbird/policy-templates/tree/master/templates/central
      # Items can be found here ^
      preferences = {
        "extensions.blocklist.enabled" = true;

        "browser.search.update" = false;
        "browser.urlbar.suggest.calculator" = true;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.urlbar.suggest.topsites" = false;
        "browser.urlbar.suggest.trending" = false;
        "browser.urlbar.suggest.yelp" = false;
        "browser.urlbar.trimURLs" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "devtools.cache.disabled" = true;
        "dom.block_download_insecure" = false;
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
}
