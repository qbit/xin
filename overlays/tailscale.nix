let
  tailscale = _: super: {
    tailscale = super.callPackage "${super.path}/pkgs/servers/tailscale" {
      buildGoModule = args:
        super.buildGo120Module (args // rec {
          version = "1.42.0";
          src = super.fetchFromGitHub {
            owner = "tailscale";
            repo = "tailscale";
            rev = "v${version}";
            hash = "sha256-J7seajRoUOG/nm5iYuiv3lcS5vTT1XxZTxiSmf/TjGI=";
          };
          vendorHash = "sha256-7L+dvS++UNfMVcPUCbK/xuBPwtrzW4RpZTtcl7VCwQs=";
          vendorSha256 = "_unset";
          ldflags = [
            "-X tailscale.com/version.longStamp=${version}"
            "-X tailscale.com/version.shortStamp=${version}"
          ];
        });
    };
  };

in tailscale
