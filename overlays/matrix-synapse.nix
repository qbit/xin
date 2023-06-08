let
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.85.2";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "matrix-org";
        repo = "synapse";
        rev = "v${version}";
        hash = "sha256-pFafBsisBPfpDnFYWcimUuBgfFVPZzLna3yHeqIBAAE=";
      };

      cargoDeps = super.rustPlatform.fetchCargoTarball {
        inherit src;
        name = "${pname}-${version}";
        sha256 = "sha256-dnno+5Ma0YNYpmj3oZ5UG22uAanKwVT67BwQW+mHoFc=";
      };
    });
  };

in matrix-synapse
