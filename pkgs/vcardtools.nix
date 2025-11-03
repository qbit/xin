{
  lib,
  buildPythonPackage,
  python,
  fetchFromGitHub,
  wheel,
  vobject,
  fuzzywuzzy,
  setuptools,
  setuptools-scm,
  ...
}:
buildPythonPackage rec {
  pname = "vcardtools";
  version = "unstable-2024-11-08";

  pyproject = false;

  src = fetchFromGitHub {
    owner = "mbideau";
    repo = pname;
    rev = "94132ec751eeb1cdf27fbece293ed32aa60b070c";
    hash = "sha256-YIbqXStOjy4R0396qLARXHUpNwh1G+o5x2q1y+yZIBs=";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  doCheck = true;

  nativeBuildInputs = [
    setuptools-scm
    setuptools
  ];

  propagatedBuildInputs = [
    wheel
    vobject
    fuzzywuzzy
  ];

  installPhase = ''
    mkdir -p $out/bin $out/libexec $out/${python.sitePackages}/libs
    install -Dm755 vcardtools.py $out/bin/${pname}
    install -Dm644 vcardlib.py $out/${python.sitePackages}/
  '';

  meta = with lib; {
    maintainers = with maintainers; [ qbit ];
    license = licenses.gpl3;
  };
}
