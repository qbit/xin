{ lib
, buildGoModule
, fetchFromGitHub
, ...
}:
with lib;
buildGoModule rec {
  pname = "golink";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = pname;
    rev = "cada6f65af471470f85092a7152023e956ce0fb4";
    sha256 = "sha256-YApJezFbihypIZx8UHqqhXQ/fw1Zz/XL6P6Z3gTFtrA=";
  };

  vendorHash = "sha256-0k+1G+ox9+NZI4GaHm2Ba2Q4Eybz20gTAPnGKkU5Iec=";

  proxyVendor = true;

  meta = {
    description = "A private shortlink service for tailnets";
    homepage = "https://github.com/tailscale/golink";
    license = licenses.bsd3;
    maintainers = with maintainers; [ qbit ];
  };
}
