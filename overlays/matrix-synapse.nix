let
  version = "1.127.1";
  hash = "sha256-DNUKbb+d3BBp8guas6apQ4yFeXCc0Ilijtbt1hZkap4=";
  sha256 = "sha256-WThWu2QDG3cLS0W1oqKL2rYQQ8qX7XVrks3Kvkx5ZDs=";
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
