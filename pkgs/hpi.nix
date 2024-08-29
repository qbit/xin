{ pkgs
, buildPythonPackage
, setuptools-scm
, pytest
, appdirs
, click
, decorator
, geopy
, logzero
, lxml
, more-itertools
, hypothesis
, mypy
, orjson
, pandas
, pytz
, simplejson
, colorlog
, ...
}:
with pkgs; let
  orgparse = pkgs.python3Packages.callPackage ./orgparse.nix { inherit pkgs; };
  cachew = pkgs.python3Packages.callPackage ./cachew.nix { inherit pkgs; };
  google_takeout_parser = pkgs.python3Packages.callPackage ./google-takeout-parser.nix { inherit pkgs; };
  kobuddy = pkgs.python3Packages.callPackage ./kobuddy.nix { inherit pkgs; };
  ghexport = pkgs.python3Packages.callPackage ./ghexport.nix { inherit pkgs; };
  kompress = buildPythonPackage rec {
    pname = "kompress";
    version = "0.1.20240829";

    pyproject = true;

    nativeBuildInputs = [ setuptools-scm ];

    src = fetchFromGitHub {
      owner = "karlicoss";
      repo = pname;
      rev = "b4127543d8ca22988335d2640f905b8d939f85a1";
      hash = "sha256-U7o5FG2FscAhbsYd/KS/vess/eJU/A2jH/WOve0anHo=";
    };
  };
in
buildPythonPackage rec {
  pname = "HPI";
  version = "0.5.20240824";

  pyproject = true;

  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [
    appdirs
    click
    decorator
    geopy
    cachew
    hypothesis
    colorlog
    kompress
    kobuddy
    logzero
    lxml
    ghexport
    more-itertools
    google_takeout_parser
    mypy
    orgparse
    orjson
    pandas
    pytest
    pytz
    simplejson
  ];

  doCheck = true;

  buildInputs = [ mypy kobuddy ];

  makeWrapperArgs = [
    # Add the installed directories to the python path so the daemon can find them
    "--prefix PYTHONPATH : ${python3.pkgs.makePythonPath propagatedBuildInputs}"
    "--prefix PYTHONPATH : $out/lib/${python3.libPrefix}/site-packages"
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  src = fetchFromGitHub {
    owner = "karlicoss";
    repo = pname;
    rev = "d58453410c34d75715b71c041f7a58a4f0954436";
    hash = "sha256-UMccXFUwcyQOQdJuR3f9OgjskUs99zR5HPZ5NjKdVRI=";
  };
}
