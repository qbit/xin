let
  hash = "sha256-4K6Sffu/yKHkcoNENbgpci2dbJVAH3vVkogcw/IYpnw=";
  heisenbridge = _: super: {
    heisenbridge = super.heisenbridge.overrideAttrs (_: rec {
      version = "1.15.0";
      pname = "heisenbridge";

      src = super.fetchFromGitHub {
        owner = "hifi";
        repo = pname;
        rev = "refs/tags/v${version}";
        inherit hash;
      };

      patches = [
        ./heisen-plumb-no-react.diff
      ];

      postPatch = ''
        echo "${version}" > heisenbridge/version.txt
      '';
    });
  };
in
heisenbridge
