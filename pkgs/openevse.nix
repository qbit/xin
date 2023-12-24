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
  version = "2.1.32";

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
    rev = version;
    hash = "sha256-7DsctUJKYR81DgJCDskCO79C8wHp0cpZP32vfjnxSHY=";
  };
}
