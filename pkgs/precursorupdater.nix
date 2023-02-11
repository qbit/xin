{ lib, buildPythonPackage, fetchPypi, pyusb, progressbar2, requests
, pycryptodome, ... }:
buildPythonPackage rec {
  pname = "precursorupdater";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-YWPWGQLFbHjhYbdhLvbWndsNPfWEPSD7rfN6pJdnZFs=";
  };

  propagatedBuildInputs = [ pyusb progressbar2 requests pycryptodome ];

  doCheck = false;

  meta = with lib; {
    homepage =
      "https://github.com/betrusted-io/betrusted-wiki/wiki/Updating-Your-Device";
    description = "script to automatically updates a Precursor device";
    license = licenses.asl20;
    maintainers = with maintainers; [ qbit ];
  };
}
