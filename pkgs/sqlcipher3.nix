{ pkgs, buildPythonPackage, setuptools-scm, sqlcipher, fetchPypi, ... }:

buildPythonPackage rec {
  pname = "sqlcipher3";
  version = "0.5.0";

  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ sqlcipher ];

  doCheck = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-+wa7UzaCWvIE6Obb/Ihema8UnFPr2P+HeDe1R4+iU+U=";
  };
}
