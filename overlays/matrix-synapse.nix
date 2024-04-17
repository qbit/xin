let
  hash = "sha256-MydtP7jtTx9phmnoAajWvDI0sSqw+TScj+9n485L5qc=";
  sha256 = "sha256-yj3biat5znDqsen0mc8MNkXKhUftpb26VT7utWdpxvc=";
  matrix-synapse-unwrapped = _: super: {
    matrix-synapse-unwrapped = super.matrix-synapse-unwrapped.overrideAttrs (_: rec {
      version = "1.105.0";
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
