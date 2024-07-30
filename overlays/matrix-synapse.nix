let
  version = "1.112.0";
  hash = "sha256-8iXw9C91kPWDlzo/3AA/iVCQqq47eGSORMTzEQTTS+8=";
  sha256 = "sha256-hx/IMOxk4vUHXMMIcnxnC3RJcIvJL+IooZnf+m+VKSs=";
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
