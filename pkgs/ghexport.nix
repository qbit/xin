{ buildPythonPackage
, setuptools-scm
, fetchFromGitHub
, PyGithub
, pytz
, ...
}:
buildPythonPackage rec {
  pname = "ghexport";
  version = "20220828";

  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ PyGithub pytz ];

  doCheck = true;

  buildInputs = [ ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  src = fetchFromGitHub {
    owner = "karlicoss";
    repo = pname;
    rev = "e7704dc5b984731a53e74cbcadcbc3dd9c3024cd";
    hash = "sha256-m/iqeBvCXHlN7GsNW6A2AX1g+ZaH3W62+Ulcfgup0KQ=";
  };
}
