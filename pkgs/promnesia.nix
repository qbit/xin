{ lib, buildPythonPackage, fetchPypi, pdm-pep517, setuptools, setuptools-scm
, appdirs, tzlocal, more-itertools, pytz, sqlalchemy, urlextract, fastapi
, websockets, uvloop, httptools, watchfiles, uvicorn, lxml, mistletoe, logzero
, decorator, click, beautifulsoup4, sqlcipher, mypy, pandas, orjson, pytest, ...
}:
let
  sqlcipher3 = buildPythonPackage rec {
    pname = "sqlcipher3";
    version = "0.5.0";

    nativeBuildInputs = [ setuptools-scm ];
    propagatedBuildInputs = [ sqlcipher ];

    doCheck = true;

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-+wa7UzaCWvIE6Obb/Ihema8UnFPr2P+HeDe1R4+iU+U=";
    };
  };
  orgparse = buildPythonPackage rec {
    pname = "orgparse";
    version = "0.3.2";

    nativeBuildInputs = [ setuptools-scm ];
    #propagatedBuildInputs = [ ];

    nativeCheckInputs = [ pytest ];

    doCheck = true;

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-RRBQ55rLelHGXcmbkJXq5NUL1ZhUE1T552PLTL31mlU=";
    };
  };
  HPI = buildPythonPackage rec {
    pname = "HPI";
    version = "0.0.20200417";

    nativeBuildInputs = [ setuptools-scm ];
    propagatedBuildInputs = [
      pytz
      appdirs
      more-itertools
      decorator
      click
      mypy
      pandas
      logzero
      orjson
      lxml
    ];

    doCheck = true;

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-cozMmfBF7D1qCZFjf48wRQaeN4MhdHAAxS8tGp/krK8=";
    };
  };
  cachew = buildPythonPackage rec {
    pname = "cachew";
    version = "0.11.0";

    nativeBuildInputs = [ setuptools-scm ];

    doCheck = true;

    propagatedBuildInputs = [ appdirs sqlalchemy ];

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-4qjgvffInKRpKST9xbwwC2+m8h3ups0ZePyJLUU+KhA=";
    };
  };
in buildPythonPackage rec {
  pname = "promnesia";
  version = "1.1.20230129";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-T6sayrPkz8I0u11ZvFbkDdOyVodbaTVkRzLib5lMX+Q=";
  };

  doCheck = true;

  nativeBuildInputs = [ pdm-pep517 setuptools-scm ];

  # Optional
  # bs4 lxml mistletoe logzero
  propagatedBuildInputs = [
    beautifulsoup4
    cachew
    fastapi
    HPI
    httptools
    logzero
    lxml
    mistletoe
    more-itertools
    mypy
    orgparse
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
