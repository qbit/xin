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
  nixpkgs.overlays = if isUnstable then [
    openssl_3

    (self: super: {
      zig = super.zig.overrideAttrs (old: {
        version = "0.10.0-dev.35e0ff7";
        src = super.fetchFromGitHub {
          owner = "ziglang";
          repo = "zig";
          rev = "10e11b60e56941cb664648dcebfd4db3d2efed30";
          hash = "sha256-oD5yfvaaVtgW/VE+5yHCiJgC+QMwiLe2i+PGX3g/PT0=";
        };

        patches = [ ];

        nativeBuildInputs = with pkgs; [ cmake llvmPackages_14.llvm.dev ];

        buildInputs = with pkgs;
          [ libxml2 zlib ] ++ (with llvmPackages_14; [ libclang lld llvm ]);

        checkPhase = ''
          runHook preCheck
          runHook postCheck
        '';

      });
    })
  ] else [
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

