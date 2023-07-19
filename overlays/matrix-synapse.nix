let
  hash = "sha256-uNk+vyOCbaoy8Jw8W5KyedIw6bJ0ci8NkFTMlBVcxEw=";
  sha256 = "sha256-ILLZUQjUbLvmNsDpCSqKAYO/PRHTJ/XTDJTo/LCT/mg=";
  matrix-synapse = _: super: {
    matrix-synapse = super.matrix-synapse.overrideAttrs (_: rec {
      version = "1.88.0";
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
