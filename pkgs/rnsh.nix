{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  rns,
  setuptools,
  setuptools-scm,
  poetry-core,
  ...
}:

buildPythonPackage rec {
  pname = "rnsh";
  version = "0.1.5";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "acehoss";
    repo = pname;
    rev = "release/v${version}";
    hash = "sha256-Dog5InfCRCxqe9pXpCAPdqGbEz2SvNOGq4BvR8oM05o=";
  };

  doCheck = true;

  nativeBuildInputs = [
    setuptools-scm
    setuptools
    poetry-core
  ];

  dependencies = [
    rns
  ];

  meta = with lib; {
    homepage = "https://github.com/acehoss/rnsh";
    description = "rnsh";
    mainProgram = "rnsh";
    maintainers = with maintainers; [ qbit ];
  };
}
