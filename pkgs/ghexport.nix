{ buildPythonPackage
, setuptools-scm
, fetchFromGitHub
, PyGithub
, pytz
, ...
}:
buildPythonPackage rec {
  pname = "ghexport";
  version = "20231020";

  pyproject = true;

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
    rev = "03207b63da4a0f570700f373867ff67deb4f43d1";
    hash = "sha256-QfYpi59q5uqOEAcxLC72972HMsgRlMngjuRULwRbmUc=";
  };
}
