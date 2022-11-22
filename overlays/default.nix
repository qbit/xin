{ self, config, pkgs, lib, isUnstable, ... }:

let
  openssh = self: super: {
    openssh = super.openssh.overrideAttrs (old: {
      version = "9.1p1";

      src = super.fetchurl {
        url = "mirror://openbsd/OpenSSH/portable/openssh-9.1p1.tar.gz";
        hash = "sha256-GfhQCcfj4jeH8CNvuxV4OSq01L+fjsX+a8HNfov90og=";
      };

      doCheck = false;
    });
  };
  tailscale = self: super: {
    tailscale = super.tailscale.overrideAttrs (old: rec {
      version = "1.32.3";
      src = super.fetchFromGitHub {
        owner = "tailscale";
        repo = "tailscale";
        rev = "v${version}";
        sha256 = "sha256-CYNHD6TS9KTRftzSn9vAH4QlinqNgU/yZuUYxSvsl/M=";
      };
      ldflags = [
        "-X tailscale.com/version.Long=${version}"
        "-X tailscale.com/version.Short=${version}"
      ];
    });
  };
in {
  nixpkgs.overlays = if isUnstable then
    [ tailscale ]
  else [
    openssh

    (self: super: {
      matrix-synapse = super.matrix-synapse.overrideAttrs (old: rec {
        version = "1.72.0";
        src = super.fetchFromGitHub {
          owner = "matrix-org";
          repo = "synapse";
          rev = "v${version}";
          sha256 = "sha256-LkzUrEXC+jonkEpAGIEDQhAKisrKNQB8/elchN/4YMU=";
        };

        cargoDeps = super.rustPlatform.fetchCargoTarball {
          inherit src;
          name = "matrix-synapse-${version}";
          sha256 = "sha256-AuQURcVaIoOYG9jh6QhPpXB0akASVWMYe4fA/376cwo=";
        };
      });
    })

  ];
}

# Example Python dep overlay
# (self: super: {
#   python3 = super.python3.override {
#     packageOverrides = python-self: python-super: {
#       canonicaljson = python-super.canonicaljson.overrideAttrs (oldAttrs: {
#         nativeBuildInputs = [ python-super.setuptools ];
#       });
#     };
#   };
# })

# Example of an overlay that changes the buildGoModule function
#tailscale = self: super: {
#  tailscale = super.callPackage "${super.path}/pkgs/servers/tailscale" {
#    buildGoModule = args:
#      super.buildGo119Module (args // rec {
#        version = "1.32.2";
#        src = super.fetchFromGitHub {
#          owner = "tailscale";
#          repo = "tailscale";
#          rev = "v${version}";
#          sha256 = "sha256-CYNHD6TS9KTRftzSn9vAH4QlinqNgU/yZuUYxSvsl/M=";
#        };
#        vendorSha256 = "sha256-VW6FvbgLcokVGunTCHUXKuH5+O6T55hGIP2g5kFfBsE=";
#      });
#  };
#};
