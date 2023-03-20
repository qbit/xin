let
  tailscale = self: super: {
    tailscale = super.callPackage "${super.path}/pkgs/servers/tailscale" {
      buildGoModule = args:
        super.buildGo120Module (args // rec {
          version = "1.38.1";
          src = super.fetchFromGitHub {
            owner = "tailscale";
            repo = "tailscale";
            rev = "v${version}";
            hash = "sha256-2VTYZhC/U32fzEJCxkCB35IqQBALKXQA23SvhY57lSU=";
          };
          vendorHash = "sha256-LIvaxSo+4LuHUk8DIZ27IaRQwaDnjW6Jwm5AEc/V95A=";
          vendorSha256 = "_unset";
          ldflags = [
            "-X tailscale.com/version.longStamp=${version}"
            "-X tailscale.com/version.shortStamp=${version}"
          ];
        });
    };
  };

in tailscale
