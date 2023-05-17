let
  jetbrains = _: super: {
    # Override jetbrains idea-ultimate until the newer version is available
    jetbrains = super.jetbrains // {
      idea-ultimate = super.jetbrains.idea-ultimate.overrideAttrs (_: rec {
        version = "2023.1.2";
        src = super.fetchurl {
          url =
            "https://download-cdn.jetbrains.com/idea/ideaIU-${version}.tar.gz";
          sha256 = "sha256-4aJgcOkb3Gp9JirtoxanKQjR/7uLUA8IZmW/zSneJJo=";
        };
      });
    };
  };
in jetbrains
