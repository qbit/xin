{
  buildPythonPackage,
  setuptools-scm,
  fetchFromGitHub,
  pyserial,
  coloredlogs,
  bleak,
  ...
}:
buildPythonPackage rec {
  pname = "ble-serial";
  version = "2.8.0";

  pyproject = true;

  nativeBuildInputs = [
    setuptools-scm
  ];

  propagatedBuildInputs = [
    pyserial
    coloredlogs
    bleak
  ];

  buildInputs = [ setuptools-scm ];

  src = fetchFromGitHub {
    owner = "jakeler";
    repo = "ble-serial";
    rev = "v${version}";
    hash = "sha256-KQCnrloBrY7hRt2cFcWiFUg5GgrdbXbcTCNcIuVryZw=";
  };
}
