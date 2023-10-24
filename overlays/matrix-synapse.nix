let
  hash = "sha256-WYKuWTOP0w9Xtao9vF3+km4mXVTrt/mshcaXuF92voQ=";
  sha256 = "sha256-uUu2Hu4a7J49S3rhZ7xsLJQC7seYkVScYYbWaw4Q/rU=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.95.0";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "matrix-org";
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
