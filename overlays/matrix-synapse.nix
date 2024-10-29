let
  version = "1.118.0";
  hash = "sha256-dMa1L1MYzt/XfCD8hGt+WupAwl5l4zwVcj5mQ8KtTp8=";
  sha256 = "sha256-FJaj5T2wMIn/A0JNUGpXyNtPvXIAF8Ivkej4vS1S3dA=";
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
