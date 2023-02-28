let
  matrix-synapse = self: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (old: rec {
      version = "1.78.0";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "matrix-org";
        repo = "synapse";
        rev = "v${version}";
        hash = "sha256-UMP/JQ77qGfAQ+adLBLB8NFI2OiuwjILEbEecEDcK1A=";
      };

      cargoDeps = super.rustPlatform.fetchCargoTarball {
        inherit src;
        name = "${pname}-${version}";
        sha256 = "sha256-UTuMvTWfOlFlL+4qsCEfVljnkeylBKq0wd5FlAOYAFQ=";
      };
    });
  };

in matrix-synapse
