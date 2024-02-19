let
  hash = "sha256-yhOdIyKp+JM0qUl4dD1aMeYHNhE71DUDxrfCyRDP1VI=";
  sha256 = "sha256-mWvcRNvCYf6WCKU/5LGJipOI032QFG90XpHTxFGs6TU=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.101.0";
      pname = "matrix-synapse";

      patches = [
        (super.fetchpatch {
          url = "https://patch-diff.githubusercontent.com/raw/element-hq/synapse/pull/16927.patch";
          sha256 = "sha256-5Iy8oA/6XeOoe0d29ahFnEIn4zBcAOKtc/Jj5k3yb7c=";
        })
      ];

      src = super.fetchFromGitHub {
        owner = "element-hq";
        repo = "synapse";
        rev = "v${version}";
        inherit hash;
      };

      cargoDeps = super.rustPlatform.fetchCargoTarball {
        inherit src sha256;
        name = "${pname}-${version}";
      };
    });
  };
in
matrix-synapse
