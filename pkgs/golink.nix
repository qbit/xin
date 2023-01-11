{ lib, buildGoModule, fetchFromGitHub, ... }:

with lib;
buildGoModule rec {
  pname = "golink";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = pname;
    rev = "3af59c51b849a19a01a47fe8bbad33dc16374201";
    sha256 = "sha256-AAVX1G0ajN/G5IK4Xf7X8mrWj7LGblGCbd+x4BUZqrw=";
  };

  vendorSha256 = "sha256-U3j5yiFhtYR0wvHD1U+DkYuFVt6NyEPlx7feLWfr3/Y=";

  proxyVendor = true;

  meta = {

    description = "A private shortlink service for tailnets";
    homepage = "https://github.com/tailscale/golink";
    license = licenses.bsd3;
    maintainers = with maintainers; [ qbit ];
  };
}
