let
  bruno = _: super: {
    bruno = super.bruno.overrideAttrs (
      _: rec {
        version = "0.25.0";
        src = super.fetchurl {
          url = "https://github.com/usebruno/bruno/releases/download/v${version}/bruno_${version}_amd64_linux.deb";
          hash = "sha256-h7GBZaYKHwZnGNZGcVtyV0cJa8EgsulDsFIB3ggYGng=";
        };
      }
    );
  };
in
bruno
