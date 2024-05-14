let
  hash = "sha256-xT9DpBBLavI7QLuyqEtTyjHoP+pQ4wlNupJFWtppwh8=";
  sha256 = "sha256-bGRIzgFNHi/4jOWMTgwA7hVcvfHROHE+nnZtTPjwpmI=";
  matrix-synapse-unwrapped = _: super: {
    matrix-synapse-unwrapped = super.matrix-synapse-unwrapped.overrideAttrs (_: rec {
      version = "1.107.0";
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
