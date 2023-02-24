let
  tailscale = self: super: {
    tailscale = super.callPackage "${super.path}/pkgs/servers/tailscale" {
      buildGoModule = args:
        super.buildGo119Module (args // rec {
          version = "1.36.2";
          src = super.fetchFromGitHub {
            owner = "tailscale";
            repo = "tailscale";
            rev = "v${version}";
            hash = "sha256-5rGRe4ENIQVz8KDy1OuSKtD7UMVYmU2DaJAn7wrhXVQ=";
          };
          vendorHash = "sha256-xdZlwv/2knOE7xaGeNHYNdztflhLLmirGzPOJpDvk3s=";
          vendorSha256 = "_unset";
          ldflags = [
            "-X tailscale.com/version.Long=${version}"
            "-X tailscale.com/version.Short=${version}"
          ];
        });
    };
  };

in tailscale
