let
  invidious = _: super: {
    invidious = super.invidious.overrideAttrs (_: {
      patches = [
        (super.fetchpatch {
          name = "use-android";
          url = "https://patch-diff.githubusercontent.com/raw/iv-org/invidious/pull/4650.diff";
          hash = "sha256-nI9T0p2i2uqB2qJgZXD1nhiBUNhpTvMPS/XNNWPWCBs=";
        })
      ];
    });
  };
in
invidious
