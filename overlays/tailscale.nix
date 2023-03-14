let
  tailscale = self: super: {
    tailscale = super.callPackage "${super.path}/pkgs/servers/tailscale" {
      buildGoModule = args:
        super.buildGo120Module (args // rec {
          version = "1.38.0";
          src = super.fetchFromGitHub {
            owner = "tailscale";
            repo = "tailscale";
            rev = "v${version}";
            hash = "sha256-eDEdllEvdZvP611x8MxlpR0QVz4N+bET407oNB3RQpQ=";
          };
          vendorHash = "sha256-LIvaxSo+4LuHUk8DIZ27IaRQwaDnjW6Jwm5AEc/V95A=";
          vendorSha256 = "_unset";
          ldflags = [
            "-X tailscale.com/version.Long=${version}"
            "-X tailscale.com/version.Short=${version}"
          ];
        });
    };
  };

in tailscale
