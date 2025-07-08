{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  setuptools-scm,
  poetry-core,
  pandoc,
  ...
}:

buildPythonPackage rec {
  pname = "obsidian-to-org";
  version = "unstable-2023-02-04";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "jml";
    repo = pname;
    rev = "9069a4e4f5f579e2d0befcafc9250935afdf5dc4";
    hash = "sha256-1omKjDYK5ykADKs+dMfETtnvxcdntcOyOlgWUKzHj8o=";
  };

  doCheck = true;

  patches = [
    ./obsidian-to-org.patch
  ];

  nativeBuildInputs = [
    setuptools-scm
    setuptools
    poetry-core
  ];

  propagatedBuildInputs = [
    pandoc
  ];

  meta = with lib; {
    homepage = "https://github.com/jml/obsidian-to-org";
    description = "obsidian-to-org";
    mainProgram = "obsidian-to-org";
    maintainers = with maintainers; [ qbit ];
  };
}
