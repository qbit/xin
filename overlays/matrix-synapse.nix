let
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.84.0";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "matrix-org";
        repo = "synapse";
        rev = "v${version}";
        hash = "sha256-CN/TCyQLlGRNDvsojGltP+GQ4UJiWQZkgQinD/w9Lfc=";
      };

      cargoDeps = super.rustPlatform.fetchCargoTarball {
        inherit src;
        name = "${pname}-${version}";
        sha256 = "sha256-MikdIo1YghDAvpVX2vUHFmz8WgupUi/TbMPIvYgGFRA=";
      };
    });
  };

in matrix-synapse
