let
  version = "1.117.0";
  hash = "sha256-fBxvEHkLo736Qp973XeXXG84MuZHOZfBHjKbcJpmtJw=";
  sha256 = "sha256-Wqpt42dubiECMPfijtb8EcsKDTsVKseZ8f6VP7QBpoo=";
  matrix-synapse-unwrapped = _: super: {
    matrix-synapse-unwrapped = super.matrix-synapse-unwrapped.overrideAttrs (_: rec {
      inherit version;
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "element-hq";
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
matrix-synapse-unwrapped
