{ isUnstable
, xinlib
, ...
}:
let
  inherit (xinlib) prIsOpen;
  matrix-synapse = prIsOpen.overlay 0 (import ./matrix-synapse.nix);
  heisenbridge = prIsOpen.overlay 0 (import ./heisenbridge.nix);
in
{
  nixpkgs.overlays = [ heisenbridge ] ++
    (if isUnstable
    then [
    ]
    else [
      matrix-synapse
    ]);
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
