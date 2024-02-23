let
  hash = "sha256-QOU539tMpAi/WIbDOF4u2L7OJ3Wk3tkGqmPbMe91pk8=";
  sha256 = "sha256-vl1ouJsHcclOZlQ+s959bh8Qn0I/d0B/XYP+Lmdi4fg=";
  matrix-synapse-unwrapped = _: super: {
    matrix-synapse-unwrapped = super.matrix-synapse-unwrapped.overrideAttrs (_: rec {
      version = "1.102.0rc1";
      pname = "matrix-synapse";

      src = super.fetchFromGitHub {
        owner = "element-hq";
        repo = "synapse";
        rev = "v${version}";
        inherit hash;
      };

      patches = [
        (super.fetchpatch {
          url = "https://github.com/element-hq/synapse/pull/16954.patch";
          sha256 = "sha256-/hm4yKAGw30Z903v4TBDuO+AmxNOMKMK8VtNPegW/VA=";
        })
      ];

      cargoDeps = super.rustPlatform.fetchCargoTarball {
        inherit src sha256;
        name = "${pname}-${version}";
      };
    });
  };
in
matrix-synapse-unwrapped
