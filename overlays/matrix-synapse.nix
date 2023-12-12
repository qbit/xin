let
  hash = "sha256-irPExb8rwQjkPp0b3x5hJG4Ay6OnITWIGRPxBSoP/Dk=";
  sha256 = "sha256-DHKhEFXquWfHfk54mTehjchg3KsB4CfzElXMt5Mp+Vg=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.98.0";
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
