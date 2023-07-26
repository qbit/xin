{
  pkgs,
  buildPythonPackage,
  setuptools,
  fetchFromGitHub,
  multimon-ng,
  ...
}:
with pkgs;
  buildPythonPackage rec {
    pname = "pymultimonaprs";
    version = "1.3.1";

    nativeBuildInputs = [setuptools];
    propagatedBuildInputs = [
      setuptools
      multimon-ng
    ];

    buildInputs = [];

    makeWrapperArgs = [
      # Add the installed directories to the python path so the daemon can find them
      "--prefix PYTHONPATH : ${python3.pkgs.makePythonPath propagatedBuildInputs}"
      "--prefix PYTHONPATH : $out/lib/${python3.libPrefix}/site-packages"
    ];

    src = fetchFromGitHub {
      owner = "qbit";
      repo = pname;
      rev = "refs/heads/py3";
      sha256 = "sha256-Tdg5hK2wi+KErdbfu8UGJ6d+WT3NbhnFV8pBMBpPAz0=";
    };
  }
