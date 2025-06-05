{
  buildPythonPackage,
  setuptools-scm,
  pytest,
  fetchFromGitHub,
  ...
}:
buildPythonPackage rec {
  pname = "orgparse";
  version = "0.4.20231004";

  pyproject = true;

  nativeBuildInputs = [ setuptools-scm ];
  #propagatedBuildInputs = [ ];

  nativeCheckInputs = [ pytest ];

  doCheck = true;

  src = fetchFromGitHub {
    owner = "karlicoss";
    repo = pname;
    rev = "da56aae64a6373ae8bab2dde9dc756f904f1d8f8";
    sha256 = "sha256-Vx7WDL6svMtlhuxXBQsh9gcCZTnVD4RV8lz6ijK6qbw=";
  };
}
