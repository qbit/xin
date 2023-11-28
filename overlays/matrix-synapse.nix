let
  hash = "sha256-KusCJj5MVmRbniI9aTjRInPMpIDZKWs5w+TImVKHrPc=";
  sha256 = "sha256-SImgV47EfKy70VmcBREu1aiZFvX0+h0Ezw+/rUZufAg=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.97.0";
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
