{ lib, buildGoModule, fetchFromGitHub, ... }:
with lib;
buildGoModule rec {
  name = "vuln";

  src = fetchFromGitHub {
    owner = "golang";
    repo = name;
    rev = "995372c58a16";
    sha256 = "sha256-xkwrgOVMcV7TNtXfuBUPdhBqumbcgG9B9NVcthMrai0=";
  };

  vendorSha256 = "sha256-BYxqE/KNvstX9qcSd411nXGWwZOmgj5iHEGRka/tt4Y=";

  proxyVendor = true;

  doCheck = false;

  subPackages = [ "cmd/govulncheck" ];

  meta = {
    description = "tools for the Go vulnerability database";
    homepage = "https://github.com/golang/vuln";
    license = licenses.isc;
    maintainers = with maintainers; [ qbit ];
  };
}
