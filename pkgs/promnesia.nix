{ lib, buildPythonPackage, fetchPypi, beautifulsoup4, fastapi, httptools, pytest
, logzero, lxml, mistletoe, more-itertools, mypy, pytz, setuptools, appdirs
, sqlalchemy, tzlocal, urlextract, uvicorn, uvloop, watchfiles, websockets
, orjson, pandas, simplejson, setuptools-scm, decorator, geopy, pkgs, ... }:
with pkgs;
let
  hpi = pkgs.python3Packages.callPackage ./hpi.nix { inherit pkgs; };
  sqlcipher3 =
    pkgs.python3Packages.callPackage ./sqlcipher3.nix { inherit pkgs; };
  cachew = pkgs.python3Packages.callPackage ./cachew.nix { inherit pkgs; };
in buildPythonPackage rec {
  pname = "promnesia";
  version = "1.1.20230129";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-T6sayrPkz8I0u11ZvFbkDdOyVodbaTVkRzLib5lMX+Q=";
  };

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

  meta = with lib; {
    homepage = "https://github.com/karlicoss/promnesia";
    description = "Another piece of your extended mind";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
