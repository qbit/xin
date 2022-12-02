{ lib, buildGoModule, fetchFromGitHub, ... }:

let vendorHash = "sha256-U3j5yiFhtYR0wvHD1U+DkYuFVt6NyEPlx7feLWfr3/Y=";

in with lib;
buildGoModule rec {
  pname = "golink";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = pname;
    rev = "0755e37a910b73b586544e2805c075dcec7d0207";
    sha256 = "sha256-zzup/TR9iRNPrEEOzhIL5PTF8iKF8NlPqXBuRKt8AEc=";
  };

  patches = [ ./golink_keyfile.diff ];

  vendorSha256 = vendorHash;

  proxyVendor = true;

  meta = {

    description = "A private shortlink service for tailnets";
    homepage = "https://github.com/tailscale/golink";
    license = licenses.bsd3;
    maintainers = with maintainers; [ qbit ];
  };
}
