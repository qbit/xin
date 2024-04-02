let
  hash = "sha256-/P7EBtXSYygUrqKQ4niI8J5zkBPZDgHCW/j2rFxRlsY=";
  sha256 = "sha256-0lCbIlEM4wIG7W5BXWIZWkS6c/BkEG13xtcnPm3LjgY=";
  matrix-synapse-unwrapped = _: super: {
    matrix-synapse-unwrapped = super.matrix-synapse-unwrapped.overrideAttrs (_: rec {
      version = "1.104.0";
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
