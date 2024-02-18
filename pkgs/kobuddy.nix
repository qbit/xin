{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchPypi,
  setuptools-scm,
  pytz,
  alembic,
  banal,
  sqlalchemy,
  ...
}:
let
  myDataset = buildPythonPackage rec {
    pname = "dataset";
    version = "1.6.0";
    format = "setuptools";

    src = fetchFromGitHub {
      owner = "pudo";
      repo = pname;
      rev = "0757b5010b600a66ed07fbb06a0e86c7bb0e09bc";
      hash = "sha256-BfIGQvXKlsydV3p93/qLYtbVujTNWqWfMg16/aENHks=";
    };

    patches = [ ./kobuddy.diff ];

    propagatedBuildInputs = [
      alembic
      banal
      sqlalchemy
    ];

    # checks attempt to import nonexistent module 'test.test' and fail
    doCheck = false;

    pythonImportsCheck = [ "dataset" ];

    meta = with lib; {
      description = "Toolkit for Python-based database access";
      homepage = "https://dataset.readthedocs.io";
      license = licenses.mit;
      maintainers = with maintainers; [ xfnw ];
    };
  };
in
buildPythonPackage rec {
  pname = "kobuddy";
  version = "0.2.20221023";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-2Al1aDx9ymr0Pw+HC2S6mXkKvsDLhM1Oto+urr9i7BY=";
  };

  doCheck = true;

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    myDataset
    pytz
  ];

  meta = with lib; {
    homepage = "https://github.com/karlicoss/promnesia";
    description = "Another piece of your extended mind";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
