let
  invidious = _: super: {
    invidious = super.invidious.overrideAttrs (_: {
      patches = [
        (super.fetchpatch {
          name = "fix-fetch";
          url = "https://patch-diff.githubusercontent.com/raw/iv-org/invidious/pull/4552.diff";
          hash = "sha256-uyAsILwxf77OZwJoTkvZ7m79w4WncTAyAr1cZbU6mhM=";
        })
      ];
    });
  };
in
invidious
