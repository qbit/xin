let
  obsidian = _: super: {
    obsidian = super.obsidian.overrideAttrs (_: rec {
      version = "1.3.5";
      filename =
        if super.stdenv.isDarwin then "Obsidian-${version}-universal.dmg" else "obsidian-${version}.tar.gz";
      src = super.fetchurl {
        url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/${filename}";
        sha256 =
          if super.stdenv.isDarwin then
            "sha256-bTIJwQqufzxq1/ZxR8rVYER82tl0pPMpKwDPr9Gz1Q4="
          else
            "sha256-jhm6ziFaJnv4prPSfOnJ/EbIRTf9rnvzAJVxnVqmWE4=";
      };
    });
  };
in
obsidian
