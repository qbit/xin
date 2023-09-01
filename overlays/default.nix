{
  isUnstable,
  xinlib,
  ...
}: let
  inherit (xinlib) prIsOpen;
  #_1password-gui = prIsOpen.overlay 235900 (import ./1password-gui.nix);
  #openssh = import ./openssh.nix;
  #obsidian = prIsOpen.overlay 235408 (import ./obsidian.nix);
  tailscale = prIsOpen.overlay 239176 import ./tailscale.nix;
  #jetbrains = prIsOpen 232308 (import ./jetbrains.nix);
  tidal-hifi = prIsOpen.overlay 238572 (import ./tidal-hifi.nix);
  matrix-synapse = prIsOpen.overlay 238845 (import ./matrix-synapse.nix);
  nixd = prIsOpen.overlay 238779 (import ./nixd.nix);
in {
  nixpkgs.overlays =
    if isUnstable
    then [
      tailscale
      tidal-hifi
      nixd
    ]
    else [
      matrix-synapse
      tailscale
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

