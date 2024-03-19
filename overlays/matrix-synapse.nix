let
  hash = "sha256-NwHX4pOM2PUf2MldaPTOzP9gOcTmILxM1Sx2HPkLBcw=";
  sha256 = "sha256-AyV0JPPJkJ4jdaw0FUXPqGF3Qkce1+RK70FkXAw+bLA=";
  matrix-synapse-unwrapped = _: super: {
    matrix-synapse-unwrapped = super.matrix-synapse-unwrapped.overrideAttrs (_: rec {
      version = "1.103.0";
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
