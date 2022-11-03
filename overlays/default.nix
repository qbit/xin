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
  openssl_3 = self: super: {
    openssl_3 = super.openssl_3.overrideAttrs (old: rec {
      pname = "openssl";
      version = "3.0.7";
      sha256 = "sha256-gwSdBComDmlvYkBqxcCL9wb9hDg/lFzyG9YentlcOW4=";
      src = super.fetchurl {
        url = "https://www.openssl.org/source/${pname}-${version}.tar.gz";
        inherit sha256;
      };
      patches = [
        ./nix-ssl-cert-file.patch
        ./openssl-disable-kernel-detection.patch
        ./use-etc-ssl-certs.patch
      ];
    });
  };
in {
  nixpkgs.overlays = if isUnstable then
    [ ]
  else [
    openssh
    openssl_3

    (self: super: {
      matrix-synapse = super.matrix-synapse.overrideAttrs (old: rec {
        version = "1.70.1";
        src = super.fetchFromGitHub {
          owner = "matrix-org";
          repo = "synapse";
          rev = "v1.70.1";
          sha256 = "sha256-/clEY3sabaDEOAAowQ896vYOvzf5Teevoa7ZkzWw+fY=";
        };

        cargoDeps = super.rustPlatform.fetchCargoTarball {
          inherit src;
          name = "matrix-synapse-1.70.1";
          sha256 = "sha256-9wxWxrn+uPcz60710DROhDqNC6FvTtnqzWiWRk8kl6A=";
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
