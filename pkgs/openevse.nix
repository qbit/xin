{ buildPythonPackage
, buildHomeAssistantComponent
, setuptools-scm
, setuptools
, fetchFromGitHub
, fetchPypi
, aiohttp
, requests
, ...
}:
let
  my-python-openevse-http = buildPythonPackage rec {
    pname = "python-openevse-http";
    version = "0.1.60";

    pyproject = true;

    nativeBuildInputs = [ setuptools ];
    propagatedBuildInputs = [
      requests
      aiohttp
    ];

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-y2ZB8dQhWjaFslaAqfvXbEE20Isa0I02qVk50O8nJJI=";
    };
  };
in
buildHomeAssistantComponent rec {
  owner = "firstof9";
  domain = "openevse";
  version = "2.1.41";

  nativeBuildInputs = [
    setuptools-scm
  ];

  propagatedBuildInputs = [
    my-python-openevse-http
  ];

  buildInputs = [ setuptools-scm ];

  src = fetchFromGitHub {
    inherit owner;
    repo = domain;
    rev = version;
    hash = "sha256-s57U6+DcfWqaH9wj0lJ41ss/jmhR74YKJZ3W3qoajRM=";
  };
}
