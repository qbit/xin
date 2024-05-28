let
  hash = "sha256-Pvn6mf1EM7Dj3N7frBzPGU9YmTDhJuAVuvXbYgjnRqk=";
  sha256 = "sha256-R4V/Z8f2nbSifjlYP2NCP0B6KiAAa+YSmpVLdzeuXWY=";
  matrix-synapse-unwrapped = _: super: {
    matrix-synapse-unwrapped = super.matrix-synapse-unwrapped.overrideAttrs (_: rec {
      version = "1.108.0";
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
