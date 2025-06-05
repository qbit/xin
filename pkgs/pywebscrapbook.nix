{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  lxml,
  flask,
  werkzeug,
  jinja2,
  commonmark,
  setuptools,
  setuptools-scm,
  ...
}:
buildPythonPackage rec {
  pname = "PyWebScrapBook";
  version = "2.6.0";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "danny0838";
    repo = pname;
    rev = version;
    hash = "sha256-0mzFSyvW3miKaEd1haaj9GMLZ39MzxBmdFr+vEHVw+o=";
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
