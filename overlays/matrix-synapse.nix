let
  hash = "sha256-RJsuvNqqUiiVw6uKkG81rqo1ZoszUHK4UIJh8MReFqo=";
  sha256 = "sha256-PoPJnSZ9QpcpVbqDMlqwgAqu0K8oornpihErLHXb6Gc=";
  matrix-synapse-unwrapped = _: super: {
    matrix-synapse-unwrapped = super.matrix-synapse-unwrapped.overrideAttrs (_: rec {
      version = "1.102.0";
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
