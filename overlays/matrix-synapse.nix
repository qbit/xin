let
  version = "1.113.0";
  hash = "sha256-8Ts2QOSugPU8Do1Mpusez9tSqiaB+UzCWWY4XJk/KRM=";
  sha256 = "sha256-Jlnv3GAobrXaO5fBq6oI9Gq8phz2/jFc+QIUYsUyeNo=";
  matrix-synapse-unwrapped = _: super: {
    matrix-synapse-unwrapped = super.matrix-synapse-unwrapped.overrideAttrs (_: rec {
      inherit version;
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
