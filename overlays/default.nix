{ isUnstable
, xinlib
, ...
}:
let
  inherit (xinlib) prIsOpen todo;
  matrix-synapse-unwrapped = prIsOpen.overlay 0 (import ./matrix-synapse.nix);
  heisenbridge = prIsOpen.overlay 0 (import ./heisenbridge.nix);
  invidious = prIsOpen.overlay 0 (import ./invidious.nix);
in
{
  nixpkgs.overlays = [
    heisenbridge
    matrix-synapse-unwrapped
    (_: super: {
      libressl = super.libressl.overrideAttrs (_: {
        doCheck = todo "libressl tests disabled when building with musl" false;
      });
    })
  ] ++
  (if isUnstable
  then [
    invidious
  ]
  else [
  ]);
}
