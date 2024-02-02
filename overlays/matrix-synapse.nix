let
  hash = "sha256-6YK/VV0ELvMJoA5ipmoB4S13HqA0UEOnQ6JbQdlkYWU=";
  sha256 = "sha256-oXIraayA6Dd8aYirRhM9Av8x7bj+WZI6o7dEr9OCtdk=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.100.0";
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
matrix-synapse
