let
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.82.0";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "matrix-org";
        repo = "synapse";
        rev = "v${version}";
        hash = "sha256-j2lsdLYN5LqnIevUkD85i1XNIJa/Vpc1NHhIf2djlis=";
      };

      cargoDeps = super.rustPlatform.fetchCargoTarball {
        inherit src;
        name = "${pname}-${version}";
        sha256 = "sha256-iEPfYZd8RWlG5z8BbzESD9O0QV60EBiIIaxm9skt8Uc=";
      };
    });
  };

in matrix-synapse
