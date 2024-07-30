{ isUnstable
, xinlib
, ...
}:
let
  inherit (xinlib) prIsOpen;
  heisenbridge = prIsOpen.overlay 0 (import ./heisenbridge.nix);
  matrix-synapse = prIsOpen.overlay 0 (import ./matrix-synapse.nix);
in
{
  nixpkgs.overlays = [
    heisenbridge
    matrix-synapse
  ] ++
  (if isUnstable
  then [
  ]
  else [
  ]);
}
