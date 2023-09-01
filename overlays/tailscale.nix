let
  version = "1.44.0";
  fetchArgs = {
    owner = "tailscale";
    repo = "tailscale";
    rev = "v${version}";
    hash = "sha256-/SiQFkhVseLkjK7ePNzNyBs0r3XE3kHJ6CDTFjdCXec=";
  };
  vendorHash = "sha256-fgCrmtJs1svFz0Xn7iwLNrbBNlcO6V0yqGPMY0+V1VQ=";
  ldflags = [
    "-X tailscale.com/version.longStamp=${version}"
    "-X tailscale.com/version.shortStamp=${version}"
  ];

  #tailscale = _: super: {
  #  tailscale = super.tailscale.overrideAttrs (_: {
  #    version = "1.44.0";
  #    src = super.fetchFromGitHub fetchArgs
  #    inherit vendorHash ldflags version;
  #    ];
  #  });
  #};

  tailscale = _: super: {
    tailscale = super.callPackage "${super.path}/pkgs/servers/tailscale" {
      buildGoModule = args:
        super.buildGo120Module (args
          // {
            src = super.fetchFromGitHub fetchArgs;
            inherit vendorHash ldflags version;
          });
    };
  };
in
  tailscale
