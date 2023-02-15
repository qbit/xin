let
  openssh = self: super: {
    openssh = super.openssh.overrideAttrs (old: rec {
      version = "9.2p1";
      src = super.fetchurl {
        url = "mirror://openbsd/OpenSSH/portable/openssh-${version}.tar.gz";
        hash = "sha256-P2bb8WVftF9Q4cVtpiqwEhjCKIB7ITONY068351xz0Y=";
      };

      extraPatches = [
        (super.fetchpatch {
          name = "ssh-keysign-7.5.patch";
          url =
            "https://raw.githubusercontent.com/NixOS/nixpkgs/c99c4998fd92f284b1c2ff542878e06ea15d3d3d/pkgs/tools/networking/openssh/ssh-keysign-8.5.patch";
          stripLen = 1;
          sha256 = "sha256-vcKosAxFtwszCJVdFPIGYTqa12ea6lxePDOgVhUlxlM=";
        })
      ];
    });
  };

in openssh
