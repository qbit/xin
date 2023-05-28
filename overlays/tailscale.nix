let
  tailscale = _: super: {
    tailscale = super.tailscale.overrideAttrs (_: rec {
      version = "1.42.0";
      src = super.fetchFromGitHub {
        owner = "tailscale";
        repo = "tailscale";
        rev = "v${version}";
        hash = "sha256-J7seajRoUOG/nm5iYuiv3lcS5vTT1XxZTxiSmf/TjGI=";
      };

      vendorHash = "sha256-7L+dvS++UNfMVcPUCbK/xuBPwtrzW4RpZTtcl7VCwQs=";

      ldflags = [
        "-X tailscale.com/version.longStamp=${version}"
        "-X tailscale.com/version.shortStamp=${version}"
      ];
    });
  };

in tailscale
