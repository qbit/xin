{ lib
, beautifulsoup4
, buildPythonPackage
, fastapi
, fetchFromGitHub
, httptools
, logzero
, lxml
, mistletoe
, more-itertools
, mypy
, pkgs
, python-dotenv
, python-magic
, pytz
, setuptools
, setuptools-scm
, sqlitebrowser
, starlette
, tzlocal
, urlextract
, uvicorn
, uvloop
, watchfiles
, websockets
, ...
}:
with pkgs; let
  hpi = pkgs.python3Packages.callPackage ./hpi.nix { inherit pkgs; };
  sqlcipher3 =
    pkgs.python3Packages.callPackage ./sqlcipher3.nix { inherit pkgs; };
  cachew = pkgs.python3Packages.callPackage ./cachew.nix { inherit pkgs; };
  google_takeout_parser = pkgs.python3Packages.callPackage ./google-takeout-parser.nix { inherit pkgs; };
in
buildPythonPackage rec {
  pname = "promnesia";
  version = "1.1.20240810";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "karlicoss";
    repo = pname;
    rev = "61f1c47992881f85748c8a184f1e0946bf69bb21";
    hash = "sha256-vBYH2xKIWDcaQ5ee6aZYCBEkFtvv+OnFirq0WeyXBrQ=";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  doCheck = true;

  nativeBuildInputs = [
    setuptools-scm
  ];

  # Optional
  # bs4 lxml mistletoe logzero
  propagatedBuildInputs = [
    beautifulsoup4
    cachew
    fastapi
    hpi
    google_takeout_parser
    python-magic
    httptools
    starlette
    logzero
    lxml
    mistletoe
    more-itertools
    mypy
    python-dotenv
    pytz
    setuptools
    sqlcipher3
    tzlocal
    urlextract
    uvicorn
    uvloop
    watchfiles
    websockets
    sqlitebrowser
  ];

  makeWrapperArgs = [
    # Add the installed directories to the python path so the daemon can find them
    "--prefix PYTHONPATH : ${python3.pkgs.makePythonPath propagatedBuildInputs}"
    "--prefix PYTHONPATH : $out/lib/${python3.libPrefix}/site-packages"
  ];

  meta = with lib; {
    homepage = "https://github.com/karlicoss/promnesia";
    description = "Another piece of your extended mind";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
