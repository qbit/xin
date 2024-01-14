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
    version = "0.1.58";

    pyproject = true;

    nativeBuildInputs = [ setuptools ];
    propagatedBuildInputs = [
      requests
      aiohttp
    ];

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-Ryjg1I51ATt+YBj5vxKhNp7NiIxXf0twYV3U+6MVpX8=";
    };
  };
in
buildHomeAssistantComponent rec {
  owner = "firstof9";
  domain = "openevse";
  version = "2.1.33";

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
    hash = "sha256-N9512bwuq1hfdcO+2TNa+Yk0HkOamYjx8xd6rNctT2c=";
  };
}
