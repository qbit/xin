let
  version = "1.52.0";
  fetchArgs = {
    owner = "tailscale";
    repo = "tailscale";
    rev = "v${version}";
    hash = "sha256-mvsDM1kOLP/1LbTzmojquEF8HGy6Kb2cqJu7EnxEHPU=";
  };
  vendorHash = "sha256-WGZkpffwe4I8FewdBHXGaLbKQP/kHr7UF2lCXBTcNb4=";
  ldflags = [
    "-X tailscale.com/version.longStamp=${version}"
    "-X tailscale.com/version.shortStamp=${version}"
  ];

  #tailscale = _: super: {
  #  tailscale = super.tailscale.overrideAttrs (_: {
  #    src = super.fetchFromGitHub fetchArgs;
  #    inherit vendorHash ldflags version;
  #  });
  #};
  tailscale = _: super: {
    tailscale = super.callPackage "${super.path}/pkgs/servers/tailscale" {
      buildGoModule =
        args:
        super.buildGo121Module (
          args
          // {
            src = super.fetchFromGitHub fetchArgs;
            inherit vendorHash ldflags version;
          }
        );
    };
  };
in
tailscale
