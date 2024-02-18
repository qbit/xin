let
  openssh = _: super: {
    openssh = super.openssh.overrideAttrs (
      _: rec {
        version = "9.3p1";
        src = super.fetchurl {
          url = "mirror://openbsd/OpenSSH/portable/openssh-${version}.tar.gz";
          hash = "sha256-6bq6dwGnalHz2Fpiw4OjydzZf6kAuFm8fbEUwYaK+Kg=";
        };

        patches = [
          ./ssh-keysign-8.5.patch
          ./dont_create_privsep_path.patch
          ./locale_archive.patch
        ];
      }
    );
  };
in
openssh
