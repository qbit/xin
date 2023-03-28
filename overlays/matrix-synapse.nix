let
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.80.0";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "matrix-org";
        repo = "synapse";
        rev = "v${version}";
        hash = "sha256-Lw6gmuI+ntOW54HQbmDoY9QYNDTu5vgtrJz6HMWWmMM=";
      };

      cargoDeps = super.rustPlatform.fetchCargoTarball {
        inherit src;
        name = "${pname}-${version}";
        sha256 = "sha256-KqPpaIJ8VuVV6f6n14/7wbA+Vtk7NvWm09bUBWuAAlY=";
      };
    });
  };

in matrix-synapse
