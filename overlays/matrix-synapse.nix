let
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.86.0";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "matrix-org";
        repo = "synapse";
        rev = "v${version}";
        hash = "sha256-vSNAISWTTT3IAeA8hxQhQNp9T3soey4vgh7v+BxI+K0=";
      };

      cargoDeps = super.rustPlatform.fetchCargoTarball {
        inherit src;
        name = "${pname}-${version}";
        sha256 = "sha256-lPLhh5FkxpBUQ5UH6eAfUIyGvHIcZHmbYBT5QUW/W4k=";
      };
    });
  };
in
  matrix-synapse
