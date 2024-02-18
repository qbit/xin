let
  signal-desktop = _: super: {
    signal-desktop = super.signal-desktop.overrideAttrs (
      old: rec {
        version = "6.34.1";
        src = super.fetchurl {
          url = "https://updates.signal.org/desktop/apt/pool/s/${old.pname}/${old.pname}_${version}_amd64.deb";
          hash = "sha256-1kffRXPQmtxIsLZVOgPXDnxUmY59q+1umy25cditRhw=";
        };
      }
    );
  };
in
signal-desktop
