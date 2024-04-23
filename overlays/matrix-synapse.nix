let
  hash = "sha256-sul9wz9NXz87ZIbvSHWYQabTW/PlwAJJ2keaO0NbHHU=";
  sha256 = "sha256-Cp1Bnf96invtmYayGfBVGwxW2jk/nRVCzueubd9HIG4=";
  matrix-synapse-unwrapped = _: super: {
    matrix-synapse-unwrapped = super.matrix-synapse-unwrapped.overrideAttrs (_: rec {
      version = "1.105.1";
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
