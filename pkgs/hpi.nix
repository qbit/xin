{
  pkgs,
  buildPythonPackage,
  setuptools-scm,
  pytest,
  fetchPypi,
  appdirs,
  click,
  decorator,
  geopy,
  logzero,
  lxml,
  more-itertools,
  mypy,
  orjson,
  pandas,
  pytz,
  simplejson,
  ...
}:
with pkgs; let
  orgparse = pkgs.python3Packages.callPackage ./orgparse.nix {inherit pkgs;};
  kobuddy = pkgs.python3Packages.callPackage ./kobuddy.nix {inherit pkgs;};
  ghexport = pkgs.python3Packages.callPackage ./ghexport.nix {inherit pkgs;};
in
  buildPythonPackage rec {
    pname = "HPI";
    version = "0.3.20230207";

    nativeBuildInputs = [setuptools-scm];
    propagatedBuildInputs = [
      appdirs
      click
      decorator
      geopy
      kobuddy
      logzero
      lxml
      ghexport
      more-itertools
      mypy
      orgparse
      orjson
      pandas
      pytest
      pytz
      simplejson
    ];

    doCheck = true;

    buildInputs = [mypy kobuddy];

    makeWrapperArgs = [
      # Add the installed directories to the python path so the daemon can find them
      "--prefix PYTHONPATH : ${python3.pkgs.makePythonPath propagatedBuildInputs}"
      "--prefix PYTHONPATH : $out/lib/${python3.libPrefix}/site-packages"
    ];

    preCheck = ''
      export HOME=$(mktemp -d)
    '';

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-i3C1Lmj6K48zVG960uv1epQm38qQnxalwy8kHnLTZrE=";
    };
  }
