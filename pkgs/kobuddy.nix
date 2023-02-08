{ lib, buildPythonPackage, fetchPypi, setuptools-scm, dataset, pytz, ... }:
buildPythonPackage rec {
  pname = "kobuddy";
  version = "0.2.20221023";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-2Al1aDx9ymr0Pw+HC2S6mXkKvsDLhM1Oto+urr9i7BY=";
  };

  doCheck = true;

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [ dataset pytz ];

  meta = with lib; {
    homepage = "https://github.com/karlicoss/promnesia";
    description = "Another piece of your extended mind";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
