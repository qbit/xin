{ lib, buildGo119Module, fetchFromGitHub, isUnstable, ... }:

with lib;
buildGo119Module rec {
  name = "vuln";

  src = fetchFromGitHub {
    owner = "golang";
    repo = name;
    rev = "27dd78d2ca392c1738e54efe513a2ecb7bf46000";
    sha256 = "sha256-G35y1V4W1nLZ+QGvIQwER9whBIBDFUVptrHx78orcI0=";
  };

  vendorSha256 = "sha256-XxX+S+hXySwbXruJXM0fK7gcxiZDiysQJcXENoh/PEg=";

  proxyVendor = true;

  doCheck = false;

  meta = {
    description = "tools for the Go vulnerability database";
    homepage = "https://github.com/golang/vuln";
    license = licenses.isc;
    maintainers = with maintainers; [ qbit ];
  };
}
