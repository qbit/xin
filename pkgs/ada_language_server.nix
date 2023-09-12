{ lib
, stdenv
, fetchFromGitHub
, pkgs
, ...
}:
let
  libadalang = stdenv.mkDerivation rec {
    pname = "libadalang";
    version = "22.0.0";

    src = fetchFromGitHub {
      owner = "AdaCore";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-/nInRma0OKmI6E8nPvQlIYStl0kcPfAudvzbEyO5jJM=";
    };

    buildInputs = with pkgs; [
      gnat12
      gprbuild
      python3
      gnatcoll-core
      gnatcoll-iconv
      gnatcoll-gmp
    ];

    makeFlags = [ "PREFIX=$(out)" ];
  };
  vss = stdenv.mkDerivation rec {
    pname = "vss";
    version = "22.0.0";

    src = fetchFromGitHub {
      owner = "AdaCore";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-IDPcIJfavlqMsxLOGrvXYv98FdYVWkCiimLcMFp3ees=";
    };

    buildInputs = with pkgs; [ gnat12 gprbuild ];

    makeFlags = [ "PREFIX=$(out)" ];
  };
  gnatdoc = stdenv.mkDerivation rec {
    pname = "gnatdoc";
    version = "2022-10-04";

    src = fetchFromGitHub {
      owner = "AdaCore";
      repo = pname;
      rev = "7cdc2eae12199bc74b84d5677288fbbd55f98c25";
      sha256 = "sha256-kA5yOd3NDkRl08o38F5CyeFrihBZktNF6di3PC+/ZLU=";
    };

    buildInputs = with pkgs; [ gnat12 gprbuild libadalang ];

    makeFlags = [ "PREFIX=$(out)" ];
  };
in
stdenv.mkDerivation rec {
  pname = "ada_language_server";
  version = "23.0.10";

  src = fetchFromGitHub {
    owner = "AdaCore";
    repo = pname;
    rev = version;
    sha256 = "sha256-ZUzym0aMjq14W9h/lDL5hVCF/i+1SFu6kccGqzmGO3E=";
  };

  buildInputs = with pkgs; [ gnat12 gprbuild python3 vss gnatdoc ];

  meta = with lib; {
    description = "Language server for Ada and SPARK";
    longDescription = ''
      Server implementing the Microsoft Language Protocol for Ada and SPARk
    '';
    homepage = "https://github.com/AdaCore/ada_language_server";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ qbit ];
  };
}
