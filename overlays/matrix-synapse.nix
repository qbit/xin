let
  hash = "sha256-irPExb8rwQjkPp0b3x5hJG4Ay6OnITWIGRPxBSoP/Dk=";
  sha256 = "sha256-DHKhEFXquWfHfk54mTehjchg3KsB4CfzElXMt5Mp+Vg=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.98.0";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "matrix-org";
        repo = "synapse";
        rev = "v${version}";
        inherit hash;
      };

      patches = [
        # Stop synapse from calculating the badge count per missed convo
        # reverts https://github.com/matrix-org/synapse/pull/793/files
        # fixes https://github.com/matrix-org/matrix-spec-proposals/pull/4076
        (super.fetchpatch {
          name = "revert-per-convo-badge.diff";
          url = "https://patch-diff.githubusercontent.com/raw/matrix-org/synapse/pull/793.patch";
          hash = "sha256-ir0iqAYtxCDx9tyX1AGwXwFzk4lpI7kaVvC7gPCMMMI=";
        })
      ];

      cargoDeps = super.rustPlatform.fetchCargoTarball {
        inherit src sha256;
        name = "${pname}-${version}";
      };
    });
  };
in
matrix-synapse
