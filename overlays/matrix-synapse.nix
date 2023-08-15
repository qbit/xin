let
  hash = "sha256-VUbEERQ/UFCroSiz8Y8EsjB+uhFQXLAsK52kM6HTjjY=";
  sha256 = "sha256-t65rvhkLryzba6eZH1thBMzV7y0y5XMbdbrTxC91blQ=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.90.0";
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
