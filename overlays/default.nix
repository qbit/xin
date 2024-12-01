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
    (_: super: {
      smug = super.smug.overrideAttrs (_: rec {
        version = "0.3.3";

        src = super.fetchFromGitHub {
          owner = "ivaaaan";
          repo = "smug";
          rev = "v${version}";
          sha256 = "sha256-dQp9Ov8Si9DfziVtX3dXsJg+BNKYOoL9/WwdalQ5TVw=";
        };
      });
    })
  ] ++
  (if isUnstable
  then [
  ]
  else [
  ]);
}
