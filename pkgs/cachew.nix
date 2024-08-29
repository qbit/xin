{ buildPythonPackage
, fetchFromGitHub
, setuptools-scm
, appdirs
, sqlalchemy
, orjson
, pytz
, ...
}:
buildPythonPackage rec {
  pname = "cachew";
  version = "0.16.20240828";

  nativeBuildInputs = [ setuptools-scm ];

  pyproject = true;

  doCheck = true;

  propagatedBuildInputs = [ appdirs sqlalchemy orjson pytz ];

  src = fetchFromGitHub {
    owner = "karlicoss";
    repo = pname;
    rev = "250f648c4b9f27fb9dfc8961d8f261faddcf5cb0";
    hash = "sha256-6UZQ6J3XSSFrrxON1/0J/zvOD0Pu5ufU13CBcTs+6vs=";
  };
}
