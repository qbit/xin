let
  tailscale = _: super: {
    tailscale = super.callPackage "${super.path}/pkgs/servers/tailscale" {
      buildGoModule = args:
        super.buildGo120Module (args // rec {
          version = "1.40.0";
          src = super.fetchFromGitHub {
            owner = "tailscale";
            repo = "tailscale";
            rev = "v${version}";
            hash = "sha256-iPf3ams613VHPesbxoBaaw9eav5p781+wEmbJ+15yfY=";
          };
          vendorHash = "sha256-lirn07XE3JOS6oiwZBMwxzywkbXHowOJUMWWLrZtccY=";
          vendorSha256 = "_unset";
          ldflags = [
            "-X tailscale.com/version.longStamp=${version}"
            "-X tailscale.com/version.shortStamp=${version}"
          ];
        });
    };
  };

in tailscale
