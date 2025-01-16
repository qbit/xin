{ buildPythonPackage
, setuptools-scm
, sqlcipher
, fetchFromGitHub
, sqlite
, ...
}:
buildPythonPackage rec {
  pname = "sqlcipher3";
  version = "0.5.3";

  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ sqlcipher sqlite ];

  doCheck = true;

  src = fetchFromGitHub {
    owner = "coleifer";
    repo = "sqlcipher3";
    rev = "0.5.3";
    hash = "sha256-eRXwovBBzEKP7K97lDXeKXWwBTO6pW9FSzKx4TAD29U=";
  };
}
