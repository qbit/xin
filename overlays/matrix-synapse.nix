let
  hash = "sha256-26w926IPkVJiPVMoJUYvIFQMv5Kc6bl7Ps1mZsZJ2Xs=";
  sha256 = "sha256-xq6qPr7gfdIleV2znUdKftkOU8MB8j55m78TJR4C5Vs=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.94.0";
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
