{
  lib,
  pkgs,
  config,
  ...
}:
let
  defaultProfile = lib.filterAttrs (_: v: v != null) {
    DefaultSearchProviderEnabled = true;
    DefaultSearchProviderSearchURL = "https://kagi.com?q={searchTerms}";
    DefaultSearchProviderSuggestURL = null;
    ExtensionInstallForcelist = [
      "ddkjiahejlhfcafbddmgiahcphecmpfh"
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp"
    ];
  };
  extraOpts = {
    BrowserSignin = 0;
    SyncDisabled = true;
    PasswordManagerEnabled = false;
    SpellcheckEnabled = true;
    # ScreenCaptureAllowed = false;
    CloudReportingEnabled = false;
    CloudProfileReportingEnabled = false;
    CloudExtensionRequestEnabled = false;
    ShowHomeButton = true;
    HomepageLocation = "https://startpage.otter-alligator.ts.net/";
    HomepageIsNewTabPage = true;
    SpellcheckLanguage = [
      "en-US"
    ];
  };
in
{
  config = lib.mkIf (config.kde.enable || config.gnome.enable || config.xfce.enable) {
    environment = {
      systemPackages = [ pkgs.ungoogled-chromium ];
      etc = {
        "chromium/policies/managed/default.json".text = builtins.toJSON defaultProfile;
        "chromium/policies/managed/extra.json".text = builtins.toJSON extraOpts;
        "opt/chrome/policies/managed/default.json".text = builtins.toJSON defaultProfile;
        "opt/chrome/policies/managed/extra.json".text = builtins.toJSON extraOpts;
      };
    };
  };
}
