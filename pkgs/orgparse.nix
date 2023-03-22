{ buildPythonPackage, setuptools-scm, pytest, fetchPypi, ... }:

buildPythonPackage rec {
  pname = "orgparse";
  version = "0.3.2";

  nativeBuildInputs = [ setuptools-scm ];
  #propagatedBuildInputs = [ ];

  nativeCheckInputs = [ pytest ];

  doCheck = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-RRBQ55rLelHGXcmbkJXq5NUL1ZhUE1T552PLTL31mlU=";
  };
}

