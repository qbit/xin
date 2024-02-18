let
  _1password-gui = _: super: {
    _1password-gui = super._1password-gui.overrideAttrs (
      _: rec {
        version = "8.10.7";
        src = super.fetchurl {
          url = "https://downloads.1password.com/linux/tar/stable/x86_64/1password-${version}.x64.tar.gz";
          sha256 = "sha256-5KMAzstoPmNgFejp21R8PcdrmUtkX3qxHYX3rV5JqyE=";
        };
      }
    );
  };
in
_1password-gui
