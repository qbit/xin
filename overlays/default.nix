{ isUnstable
, xinlib
, ...
}:
let
  inherit (xinlib) prIsOpen todo;
  matrix-synapse-unwrapped = prIsOpen.overlay 0 (import ./matrix-synapse.nix);
  heisenbridge = prIsOpen.overlay 0 (import ./heisenbridge.nix);
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
    (_: super: {
      neovim-unwrapped = super.neovim-unwrapped.overrideAttrs (_: rec {
        version = "0.9.5";
        src = super.fetchFromGitHub {
          owner = "neovim";
          repo = "neovim";
          rev = "v${version}";
          hash = "sha256-CcaBqA0yFCffNPmXOJTo8c9v1jrEBiqAl8CG5Dj5YxE=";
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
