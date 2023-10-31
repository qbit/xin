let
  hash = "sha256-5RyJCMYsf6p9rd1ATEHa+FMV6vv3ULbcx7PXxMSUGSU=";
  sha256 = "sha256-gNjpML+j9ABv24WrAiJI5hoEoIqcVPL2I4V/W+sWFSg=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.95.1";
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
