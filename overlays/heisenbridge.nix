let
  hash = "sha256-IKvB3L5xgAGLkN67rw2dp4Nvv0w4XbeXMcMmY7SGeNU=";
  heisenbridge = _: super: {
    heisenbridge = super.heisenbridge.overrideAttrs (_: rec {
      version = "1.14.3";
      pname = "heisenbridge";

      src = super.fetchFromGitHub {
        owner = "hifi";
        repo = pname;
        rev = "refs/tags/v${version}";
        inherit hash;
      };
    });
  };
in
  heisenbridge
