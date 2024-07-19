{ isUnstable
, xinlib
, ...
}:
let
  inherit (xinlib) prIsOpen;
  matrix-synapse-unwrapped = prIsOpen.overlay 0 (import ./matrix-synapse.nix);
  heisenbridge = prIsOpen.overlay 0 (import ./heisenbridge.nix);
in
{
  nixpkgs.overlays = [
    heisenbridge
    matrix-synapse-unwrapped
  ] ++
  (if isUnstable
  then [
  ]
  else [
  ]);
}
