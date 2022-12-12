{ lib, buildGoModule, fetchFromGitHub, ... }:

let vendorHash = "sha256-U3j5yiFhtYR0wvHD1U+DkYuFVt6NyEPlx7feLWfr3/Y=";

in with lib;
buildGoModule rec {
  pname = "golink";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = pname;
    rev = "5fefe2519ffd9f1c6a3dd86a764d69717ee66d20";
    sha256 = "sha256-H4mwyQVFH/Yp6gIpN1o+L7S3Rupwbxl5CCLltcBh1Vk=";
  };

  vendorSha256 = vendorHash;

  proxyVendor = true;

  meta = {

    description = "A private shortlink service for tailnets";
    homepage = "https://github.com/tailscale/golink";
    license = licenses.bsd3;
    maintainers = with maintainers; [ qbit ];
  };
}
