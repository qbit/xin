let
  hash = "sha256-FnWYfFlzl6+K5dLhJ+mdphC6E6cA+HewGTUXakRHKEo=";
  sha256 = "sha256-7X0lXiD+7irex8A3Tnfq65P6BinMje4Bc1MuCI3dSyg=";
  matrix-synapse-unwrapped = _: super: {
    matrix-synapse-unwrapped = super.matrix-synapse-unwrapped.overrideAttrs (_: rec {
      version = "1.106.0";
      pname = "matrix-synapse";

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
matrix-synapse-unwrapped
