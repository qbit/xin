{ lib
, buildPythonPackage
, fetchFromGitHub
, lxml
, flask
, werkzeug
, jinja2
, commonmark
, setuptools
, setuptools-scm
, ...
}:
buildPythonPackage rec {
  pname = "PyWebScrapBook";
  version = "2.2.0";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "danny0838";
    repo = pname;
    rev = version;
    hash = "sha256-VqoYvAda1TwqwzdDc8SqAGGJcOomGEp1K6bhb9jY+k8=";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  doCheck = true;

  nativeBuildInputs = [
    setuptools-scm
    setuptools
  ];

  propagatedBuildInputs = [
    lxml
    flask
    werkzeug
    jinja2
    commonmark
  ];


  meta = with lib; {
    homepage = "https://github.com/danny0838/PyWebScrapBook";
    description = "webscrapbook";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
