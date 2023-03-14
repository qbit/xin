let
  matrix-synapse = self: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (old: rec {
      version = "1.79.0";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "matrix-org";
        repo = "synapse";
        rev = "v${version}";
        hash = "sha256-2MHP4Gu+C5yyXObbd7NLYWCy1E0L7fUwpzYsoD7ULDo=";
      };

      cargoDeps = super.rustPlatform.fetchCargoTarball {
        inherit src;
        name = "${pname}-${version}";
        sha256 = "sha256-yDKs6KRStjJMC/48dZcyQ4OmBXY1TombjH/ZDfBJbSc=";
      };
    });
  };

in matrix-synapse
