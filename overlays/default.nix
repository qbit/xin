{ isUnstable
, xinlib
, ...
}:
let
  inherit (xinlib) prIsOpen;
  tailscale = prIsOpen.overlay 0 import ./tailscale.nix;
  matrix-synapse = prIsOpen.overlay 0 (import ./matrix-synapse.nix);
  heisenbridge = prIsOpen.overlay 0 (import ./heisenbridge.nix);
in
{
  nixpkgs.overlays =
    if isUnstable
    then [
      tailscale
      heisenbridge
      (_: super: {
        cloud-hypervisor = super.cloud-hypervisor.overrideAttrs (_: {
          cargoTestFlags = [ "--bins" ];
        });
      })
      (_: super: {
        clementine = super.clementine.overrideAttrs (_: {
          patches = [
            (super.fetchpatch {
              name = "clementine-di-radio-fix.diff";
              url = "https://patch-diff.githubusercontent.com/raw/clementine-player/Clementine/pull/7217.diff";
              hash = "sha256-kaKc2YFkXJRPibbKbBCHvlm6Y/H9zS83ohMxtUNUFlM=";
            })
          ];
        });
      })
    ]
    else [
      #rex
      (_: super: {
        python3 = super.python3.override {
          packageOverrides = _: python-super: {
            pillow = python-super.pillow.overrideAttrs (_: rec {
              version = "10.0.1";
              src = python-super.fetchPypi {
                pname = "Pillow";
                inherit version;
                hash = "sha256-1ylnsGvpMA/tXPvItbr87sSL983H2rZrHSVJA1KHGR0=";
              };
            });
          };
        };
      })
      matrix-synapse
      heisenbridge
      (_: super: {
        invidious = super.invidious.overrideAttrs (_: {
          patches = [
            (super.fetchpatch {
              name = "invidious-newpipe.diff";
              url = "https://patch-diff.githubusercontent.com/raw/iv-org/invidious/pull/4037.patch";
              hash = "sha256-KyqQtmfIPIX48S8SZnSlvCLvdw6Ws1u0oWEk8jLKWlU=";
            })
          ];
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
