let
  hash = "sha256-fmY5xjpbFwzrX47ijPxOUTI0w9stYVPpSV+HRF4GdlA=";
  sha256 = "sha256-9cCEfDV5X65JublgkUP6NVfMIObPawx+nXTmIG9lg5o=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.93.0";
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
