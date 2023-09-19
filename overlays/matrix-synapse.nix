let
  hash = "sha256-oKelt/pdsFPCrcS0aTE6e9dNRB+8zMoXXRKIpIp+5Vs=";
  sha256 = "sha256-A+H7g3pxVNkZNJYEdnUkWz6xa4qkw524pHDkrtY1ZLw=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.93.0rc1";
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
