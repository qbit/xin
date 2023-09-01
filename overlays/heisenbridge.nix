let
  hash = "sha256-OmAmgHM+EmJ3mUY4lPBxIv2rAq8j2QEeTUMux7ZBfRE=";
  heisenbridge = _: super: {
    heisenbridge = super.heisenbridge.overrideAttrs (_: rec {
      version = "1.14.5";
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
