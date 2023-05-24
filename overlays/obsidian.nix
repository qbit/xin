let
  obsidian = _: super: {
    obsidian = super.obsidian.overrideAttrs (_: rec {
      version = "1.3.4";
      filename = if super.stdenv.isDarwin then "Obsidian-${version}-universal.dmg" else "obsidian-${version}.tar.gz";
      src = super.fetchurl {
        url =
          "https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/${filename}";
        sha256 = if super.stdenv.isDarwin then
          "sha256-LP13smLy/cr0hiLl5cdRxTbDfRFojb+HJBx/MFeJ13Y="
        else
          "sha256-8M9HU20IxTvPaa6x1X41Ldq2usK2TPU71VvprerivZg=";
      };

    });
  };

in obsidian
