let
  version = "1.110.0";
  hash = "sha256-DsDQgmHDU+iJ+00p1uch9Zj6lleDvdTQMy05hi8R9CM=";
  sha256 = "sha256-J0JBp9pCP00Cjs6T4litjhY28mq0OJDBrRZVSQaS03w=";
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
