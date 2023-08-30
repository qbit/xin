let
  hash = "sha256-rLEewCN8OdZ4wIWQRbLkxVF/VOAESTLAVQLfUu/PYsA=";
  sha256 = "sha256-aOoSvT6e2x7JcXoQ2sVTCDvkWupixLzpbk3cTHVQs7I=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.91.0";
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
