{ self, config, pkgs, lib, isUnstable, ... }:

let
  openssh = self: super: {
    openssh = super.openssh.overrideAttrs (old: {
      version = "9.1p1";

      src = super.fetchurl {
        url = "mirror://openbsd/OpenSSH/portable/openssh-9.1p1.tar.gz";
        hash = "sha256-GfhQCcfj4jeH8CNvuxV4OSq01L+fjsX+a8HNfov90og=";
      };
    });
  };
in {
  nixpkgs.overlays = if isUnstable then [
    openssh
    (self: super: {
      matrix-synapse = super.matrix-synapse.overrideAttrs (old: rec {
        version = "1.69.0";
        src = super.python3.pkgs.fetchPypi {
          pname = "matrix_synapse";
          version = "1.69.0";
          hash = "sha256-PfSfqaz3jdRJ1F++eqFnOxymoSEJpBBbyRU36+EPXcU=";
        };

        cargoDeps = super.rustPlatform.fetchCargoTarball {
          inherit src;
          name = "matrix-synapse-1.69.0";
          sha256 = "sha256-RJq4mdPtnAR45rAycGDSSuvZwkJPOiqFBp+8mnBTKvU=";
        };
      });
    })

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
  ] else
    [ openssh ];
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

