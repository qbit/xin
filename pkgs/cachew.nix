{ buildPythonPackage
, fetchPypi
, setuptools-scm
, appdirs
, sqlalchemy
, ...
}:
buildPythonPackage rec {
  pname = "cachew";
  version = "0.11.0";

  nativeBuildInputs = [ setuptools-scm ];

  doCheck = true;

  propagatedBuildInputs = [ appdirs sqlalchemy ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-4qjgvffInKRpKST9xbwwC2+m8h3ups0ZePyJLUU+KhA=";
  };
}
