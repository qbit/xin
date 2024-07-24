{ isUnstable
, xinlib
, ...
}:
let
  inherit (xinlib) prIsOpen;
  heisenbridge = prIsOpen.overlay 0 (import ./heisenbridge.nix);
in
{
  nixpkgs.overlays = [
    heisenbridge
  ] ++
  (if isUnstable
  then [
  ]
  else [
  ]);
}
