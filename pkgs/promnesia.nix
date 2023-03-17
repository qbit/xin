{ lib, buildPythonPackage, fetchFromGitHub, beautifulsoup4, fastapi, httptools
, pytest, logzero, lxml, mistletoe, more-itertools, mypy, pytz, setuptools
, appdirs, sqlalchemy, tzlocal, urlextract, uvicorn, uvloop, watchfiles
, websockets, orjson, pandas, simplejson, setuptools-scm, decorator, geopy, pkgs
, ... }:
with pkgs;
let
  hpi = pkgs.python3Packages.callPackage ./hpi.nix { inherit pkgs; };
  sqlcipher3 =
    pkgs.python3Packages.callPackage ./sqlcipher3.nix { inherit pkgs; };
  cachew = pkgs.python3Packages.callPackage ./cachew.nix { inherit pkgs; };
in buildPythonPackage rec {
  pname = "promnesia";
  version = "1.1.20230129";

  src = fetchFromGitHub {
    owner = "karlicoss";
    repo = pname;
    rev = "c4a7b47e198a3822dd540968c5a8e6b95ab51b53";
    hash = "sha256-QMqvqspuqkyIsz05aA1xObT0tKaJmbts3Cn3O9rlQ1k=";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  doCheck = true;

  nativeBuildInputs = [ setuptools-scm ];

  # Optional
  # bs4 lxml mistletoe logzero
  propagatedBuildInputs = [
    beautifulsoup4
    cachew
    fastapi
    hpi
    httptools
    logzero
    lxml
    mistletoe
    more-itertools
    mypy
    pytz
    setuptools
    sqlcipher3
    tzlocal
    urlextract
    uvicorn
    uvloop
    watchfiles
    websockets
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
