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
    version = "0.1.59";

    pyproject = true;

    nativeBuildInputs = [ setuptools ];
    propagatedBuildInputs = [
      requests
      aiohttp
    ];

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-SJiTt7nMn1u3EGs4RWANGEHrEtoWAlit9UWeKbcnNh4=";
    };
  };
in
buildHomeAssistantComponent rec {
  owner = "firstof9";
  domain = "openevse";
  version = "2.1.34";

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
    hash = "sha256-ZTNqtqIKug4OSfKnBmcAL1ESxSiP0yu1/6rPnK9SekU=";
  };
}
