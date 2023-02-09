let
  tailscale = self: super: {
    tailscale = super.callPackage "${super.path}/pkgs/servers/tailscale" {
      buildGoModule = args:
        super.buildGo119Module (args // rec {
          version = "1.36.1";
          src = super.fetchFromGitHub {
            owner = "tailscale";
            repo = "tailscale";
            rev = "v${version}";
            sha256 = "sha256-xTfMq8n9Io99qg/cc7SAWelcxXaWr21IQhsICeDCDNU=";
          };
          vendorSha256 = "sha256-xdZlwv/2knOE7xaGeNHYNdztflhLLmirGzPOJpDvk3s=";
          ldflags = [
            "-X tailscale.com/version.Long=${version}"
            "-X tailscale.com/version.Short=${version}"
          ];
        });
    };
  };

in tailscale
