let
  hash = "sha256-SOQp+mqADO+iwvKPA50IdxBvVzMiUUZ7f1hwXQYyopA=";
  sha256 = "sha256-vkM1U9L9PGDZFw64KAQyRQWtewRzXXWhk35m23x6o+8=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.91.1";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "matrix-org";
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
