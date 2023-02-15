let
  openssh = self: super: {
    openssh = super.openssh.overrideAttrs (old: rec {
      version = "9.2p1";
      src = super.fetchurl {
        url = "mirror://openbsd/OpenSSH/portable/openssh-${version}.tar.gz";
        hash = "sha256-P2bb8WVftF9Q4cVtpiqwEhjCKIB7ITONY068351xz0Y=";
      };

      patches = [
        ./ssh-keysign-8.5.patch
        ./dont_create_privsep_path.patch
        ./locale_archive.patch
      ];
    });
  };

in openssh
