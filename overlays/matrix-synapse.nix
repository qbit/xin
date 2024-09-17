let
  version = "1.115.0";
  hash = "sha256-R7TAuAdEGvk/cAttxbrOZkZfsfbrsPujt0zVcp3aDZQ=";
  sha256 = "sha256-h84Hp+vhGfunbD3nRb1EXPnGhnMXncjk3ASKdRr805Y=";
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
