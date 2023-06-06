let
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.85.0";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "matrix-org";
        repo = "synapse";
        rev = "v${version}";
        hash = "sha256-YC0cFnmesZZJz/v6sCsy+nWhor1mwwQXDoIK0Pq0WcY=";
      };

      cargoDeps = super.rustPlatform.fetchCargoTarball {
        inherit src;
        name = "${pname}-${version}";
        sha256 = "sha256-ox0PldDR9L7TYwxCh3L8rw4ZYA1sUdokJZwCySyPU8g=";
      };
    });
  };

in matrix-synapse
