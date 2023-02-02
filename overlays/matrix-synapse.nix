let
  matrix-synapse = self: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (old: rec {
      version = "1.76.0";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "matrix-org";
        repo = "synapse";
        rev = "v${version}";
        hash = "sha256-kPc6T8yLe1TDxPKLnK/TcU+RUxAVIq8qsr5JQXCXyjM=";
      };

      cargoDeps = super.rustPlatform.fetchCargoTarball {
        inherit src;
        name = "${pname}-${version}";
        hash = "sha256-tXtnVYH9uWu0nHHx53PgML92NWl3qcAcnFKhiijvQBc=";
      };
    });
  };

in matrix-synapse
