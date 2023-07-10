{ lib, buildGoModule, fetchFromGitHub, ... }:
with lib;
buildGoModule rec {
  name = "vuln";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "golang";
    repo = name;
    rev = "v${version}";
    sha256 = "sha256-0lb1GwOcEpchT3TkdSve335bjYbVsuVzq1SvCDwtX/Q=";
  };

  vendorSha256 = "sha256-r9XshbgVA5rppJF46SFYPad344ZHMLWTHTnL6vbIFH8=";

  #>   github.com/tidwall/pretty@v1.2.0: is explicitly required in go.mod, but not marked as explicit in vendor/modules.txt
  doCheck = false;

  subPackages = [ "cmd/govulncheck" ];

  meta = {
    description = "tools for the Go vulnerability database";
    homepage = "https://github.com/golang/vuln";
    license = licenses.isc;
    maintainers = with maintainers; [ qbit ];
  };
}
