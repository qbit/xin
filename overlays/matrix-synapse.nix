let
  hash = "sha256-AUaHgMKte1EIfI0EQm8YeQVtlXGTm+MZwq22WzYHGsE=";
  sha256 = "sha256-KwRNn2Ypt87QRUTCsj00zsu6uQtP5MSuM6B2DemoFGs=";
  matrix-synapse-unwrapped = _: super: {
    matrix-synapse-unwrapped = super.matrix-synapse-unwrapped.overrideAttrs (_: rec {
      version = "1.109.0";
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
