let
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.83.0";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "matrix-org";
        repo = "synapse";
        rev = "v${version}";
        hash = "sha256-7LMNLXTBkY7ib9DWpwccVrHxulUW8ScFr37hSGO72GM=";
      };

      cargoDeps = super.rustPlatform.fetchCargoTarball {
        inherit src;
        name = "${pname}-${version}";
        sha256 = "sha256-tzkJtkAbZ9HmOQq2O7QAbRb5pYS/WoU3k1BJhZAE6OU=";
      };
    });
  };

in matrix-synapse
