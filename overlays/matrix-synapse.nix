let
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.85.1";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "matrix-org";
        repo = "synapse";
        rev = "v${version}";
        hash = "sha256-I/InjuTJOwYXw98qW7zT+fTnyLUo96xsVkFGSL+x+5k=";
      };

      cargoDeps = super.rustPlatform.fetchCargoTarball {
        inherit src;
        name = "${pname}-${version}";
        sha256 = "sha256-KE56crjZDM1cJnVS7MvObIQ7NvH7+fUm1Mlb6HcT9+U=";
      };
    });
  };

in matrix-synapse
