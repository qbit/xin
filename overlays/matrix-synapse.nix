let
  matrix-synapse = self: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (old: rec {
      version = "1.77.0";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "matrix-org";
        repo = "synapse";
        rev = "v${version}";
        hash = "sha256-//1BTiNH3n2eNjwOADb1OB7xp5QsH6arV5Pg3B7y3r0=";
      };

      cargoDeps = super.rustPlatform.fetchCargoTarball {
        inherit src;
        name = "${pname}-${version}";
        hash = "sha256-B9Z+7VtbbX/S01aaMFHgXH60sg8Lmwku2XPRnpMpwjo=";
      };
    });
  };

in matrix-synapse
