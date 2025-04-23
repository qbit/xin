{ buildHomeAssistantComponent
, fetchFromGitHub
, home-assistant
, ...
}:
let
  my-python-openevse-http = home-assistant.python.pkgs.buildPythonPackage rec {
    pname = "python-openevse-http";
    version = "0.1.83";

    pyproject = true;

    nativeBuildInputs = with home-assistant.python.pkgs; [ setuptools-scm setuptools ];
    propagatedBuildInputs = with home-assistant.python.pkgs; [
      requests
      aiohttp
    ];

    src = fetchFromGitHub {
      owner = "firstof9";
      repo = pname;
      rev = version;
      hash = "sha256-u6WFOJjr+GlPrkA2/fjuWglOl0JDg0frvFgbXyr0El4=";
    };
  };
in
buildHomeAssistantComponent rec {
  domain = "openevse";
  owner = "firstof9";
  version = "2.1.48";

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
    hash = "sha256-qBaI9bvtJl9q2md8QOz298rQfM7JlmzC00rBcMXmqfc=";
  };
}
