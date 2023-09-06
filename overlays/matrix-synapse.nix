let
  hash = "sha256-U9SyDmO34s9PjLPnT1QYemGeCmKdXRaQvEC8KKcFXOI=";
  sha256 = "sha256-q3uoT2O/oTVSg6olZohU8tiWahijyva+1tm4e1GWGj4=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.91.2";
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
