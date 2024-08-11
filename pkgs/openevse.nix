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
    version = "0.1.61";

    pyproject = true;

    nativeBuildInputs = [ setuptools ];
    propagatedBuildInputs = [
      requests
      aiohttp
    ];

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-wwo5D2kaPb4LfI8N3k0L+4FFZBlq2qG+d3sk/OpoExA=";
    };
  };
in
buildHomeAssistantComponent rec {
  owner = "firstof9";
  domain = "openevse";
  version = "2.1.45";

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
    hash = "sha256-Z+YX9JdfmcZPrD6KHg5ZjLJY9vtR4VQM0l1Vu5SZ+m8=";
  };
}
