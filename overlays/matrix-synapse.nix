let
  version = "1.119.0";
  hash = "sha256-+3FrxSfQteIga5uiRNzAlV+xNESB9PUX/UkkL6UMETQ=";
  sha256 = "sha256-c/19RaBmtfKkFFQyDBwH+yqHp4YNQSqCu23WYbpOc98=";
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
