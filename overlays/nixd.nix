let
  nixd = _: super: {
    nixd = super.nixd.overrideAttrs (
      _: rec {
        version = "1.1.0";
        src = super.fetchFromGitHub {
          owner = "nix-community";
          repo = "nixd";
          rev = version;
          hash = "sha256-zeBVh9gPMR+1ETx0ujl+TUSoeHHR4fkQfxyOpCDKP9M=";
        };
        nativeBuildInputs = with super.pkgs; [
          meson
          ninja
          pkg-config
          bison
          flex
        ];
      }
    );
  };
in
nixd
