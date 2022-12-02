{ lib, buildPythonPackage, fetchPypi, pyusb, progressbar2, requests, ... }:
buildPythonPackage rec {
  pname = "precursorupdater";
  version = "0.0.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-/wjX6iVbM6gdBwRKMnM/u8F3hSGoO/mFzOqa9moOhss=";
  };

  propagatedBuildInputs = [ pyusb progressbar2 requests ];

  doCheck = false;

  meta = with lib; {
    homepage =
      "https://github.com/betrusted-io/betrusted-wiki/wiki/Updating-Your-Device";
    description = "script to automatically updates a Precursor device";
    license = licenses.asl20;
    maintainers = with maintainers; [ qbit ];
  };
}
