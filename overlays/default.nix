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
  nixpkgs.overlays = [ heisenbridge matrix-synapse ] ++
    (if isUnstable
    then [
    ]
    else [
    ]);
}
