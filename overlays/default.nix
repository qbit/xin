{
  isUnstable,
  xinlib,
  ...
}: let
  inherit (xinlib) prIsOpen;
  #_1password-gui = prIsOpen.overlay 235900 (import ./1password-gui.nix);
  #openssh = import ./openssh.nix;
  #obsidian = prIsOpen.overlay 235408 (import ./obsidian.nix);
  #tailscale = prIsOpen.overlay 239176 import ./tailscale.nix;
  #tidal-hifi = prIsOpen.overlay 239732 (import ./tidal-hifi.nix);
  matrix-synapse = prIsOpen.overlay 0 (import ./matrix-synapse.nix);
  #nixd = prIsOpen.overlay 238779 (import ./nixd.nix);
  heisenbridge = prIsOpen.overlay 0 (import ./heisenbridge.nix);
  rex = prIsOpen.overlay 0 (import ./rex.nix);
in {
  nixpkgs.overlays =
    if isUnstable
    then [
      rex
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
      rex
      matrix-synapse
      heisenbridge
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

