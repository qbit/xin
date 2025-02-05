{ buildHomeAssistantComponent
, fetchFromGitHub
, fetchPypi
, home-assistant
, ...
}:
let
  my-python-openevse-http = home-assistant.python.pkgs.buildPythonPackage rec {
    pname = "python-openevse-http";
    version = "0.1.61";

    pyproject = true;

    nativeBuildInputs = with home-assistant.python.pkgs; [ setuptools-scm setuptools ];
    propagatedBuildInputs = with home-assistant.python.pkgs; [
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

  nativeBuildInputs = with home-assistant.python.pkgs; [
    setuptools-scm
    setuptools
  ];

  propagatedBuildInputs = [
    my-python-openevse-http
  ];

  src = fetchFromGitHub {
    inherit owner;
    repo = domain;
    rev = version;
    hash = "sha256-Z+YX9JdfmcZPrD6KHg5ZjLJY9vtR4VQM0l1Vu5SZ+m8=";
  };
}
