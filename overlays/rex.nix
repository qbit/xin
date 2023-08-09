let
  hash = "sha256-An0wQu+UC2dZDlmJ6W8irh5nunRIlcXdPbVpwFE3Alw=";
  rex = _: super: {
    rex = super.rex.overrideAttrs (_: rec {
      pname = "Rex";
      version = "1.14.3";
      src = super.fetchurl {
        url = "mirror://cpan/authors/id/F/FE/FERKI/Rex-${version}.tar.gz";
        inherit hash;
      };
    });
  };
in
  rex
