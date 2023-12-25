{ buildPythonPackage
, buildHomeAssistantComponent
, setuptools-scm
, setuptools
, fetchFromGitHub
, fetchPypi
, ...
}:
let
  python-openevse-http = buildPythonPackage rec {
    pname = "python-openevse-http";
    version = "0.1.57";

    pyproject = true;

    nativeBuildInputs = [ setuptools ];

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-fyoXjOwsublB8K4MSaOirTH1r1g3ZxokQdMmglP51Fw=";
    };
  };
in
buildHomeAssistantComponent rec {
  owner = "firstof9";
  domain = "openevse";
  version = "unstable-2023-12-22";

  nativeBuildInputs = [
    setuptools-scm
  ];

  propagatedBuildInputs = [
    python-openevse-http
  ];

  buildInputs = [ setuptools-scm ];

  src = fetchFromGitHub {
    inherit owner;
    repo = domain;
    #rev = version;
    rev = "5d2924858799ceb31573c32056cfbf3b9868f2eb";
    hash = "sha256-NQWyDIYtST21pmYTsejep6H3wEr5Gj3BTFA4FgUk/1g=";
  };
}
