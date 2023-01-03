{ self, config, pkgs, lib, isUnstable, ... }:
let go = self: super: {
        go = super.go_1_19.overrideAttrs (old: {
          patches = old.patches ++ [
            ./452438.diff
          ];
        });
};
go1_19 = self: super: {
        go_1_19 = super.go_1_19.overrideAttrs (old: {
          patches = old.patches ++ [
            ./452438.diff
          ];
        });
};
in {
  nixpkgs.overlays = if isUnstable then
    [
      (self: super: {
        aerc = super.aerc.overrideAttrs (old: {
          patches = [
            (pkgs.fetchurl {
              url =
                "https://lists.sr.ht/~rjarry/aerc-devel/%3C20221218160541.680374-1-moritz%40poldrack.dev%3E/raw";
              sha256 = "sha256-qPRMOuPs5Pxiu2p08vGxsoO057Y1rVltPyBMbJXsH1s=";
            })
          ];
        });
      })
    ]
  else
    [
      go
      go1_19
      (self: super: {
        matrix-synapse = super.matrix-synapse.overrideAttrs (old: rec {
          version = "1.74.0";
          src = super.fetchFromGitHub {
            owner = "matrix-org";
            repo = "synapse";
            rev = "v${version}";
            sha256 = "sha256-UsYodjykcLOgClHegqH598kPoGAI1Z8bLzV5LLE6yLg=";
          };

          cargoDeps = super.rustPlatform.fetchCargoTarball {
            inherit (self) src;
            name = "matrix-synapse-${version}";
            sha256 = "sha256-XOW9DRUhGIs8x5tQ9l2A85sNv736uMmfC72f8FX3g/I=";
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
