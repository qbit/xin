let
  jetbrains = _: super: {
      # Override jetbrains idea-ultimate until the newer version is available
      jetbrains =
        super.jetbrains
        // {
          idea-ultimate = super.jetbrains.idea-ultimate.overrideAttrs (_: rec {
            version = "2022.3.3";
            src = super.fetchurl {
              url = "https://download-cdn.jetbrains.com/idea/ideaIU-${version}.tar.gz";
              sha256 = "sha256-wwK9hLSKVu8bDwM+jpOg2lWQ+ASC6uFy22Ew2gNTFKY=";
            };
          });
        };
    };
in jetbrains
