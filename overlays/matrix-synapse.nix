let
  hash = "sha256-rC7gFo/PISbrnMJeuu0ZPbHvdfnFSWaVVfekTA9HoKA=";
  sha256 = "sha256-rUkwTK7TwInoJ/R0o4PTYPNKW1Lnz6w6NKqv/r5PM1Y=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.96.1";
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
