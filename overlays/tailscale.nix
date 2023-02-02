let
  tailscale = self: super: {
    tailscale = super.callPackage "${super.path}/pkgs/servers/tailscale" {
      buildGoModule = args:
        super.buildGo119Module (args // rec {
          version = "1.36.0";
          src = super.fetchFromGitHub {
            owner = "tailscale";
            repo = "tailscale";
            rev = "v${version}";
            sha256 = "sha256-hNyEABs/GdfOx6vLTVBgbOzkbFvEDYZ0y1y0a0mIsfA=";
          };
          vendorSha256 = "sha256-Jy3kjUA8qLhcw9XLw4Xo1zhD+IWZrDNM79TsbnKpx/g=";
          ldflags = [
            "-X tailscale.com/version.Long=${version}"
            "-X tailscale.com/version.Short=${version}"
          ];
        });
    };
  };

in tailscale
