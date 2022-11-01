{ lib, buildGoModule, fetchFromGitHub, isUnstable, ... }:

let
  vendorHash = if isUnstable then
    "sha256-d8YeLD/BQAB6IC4jvBke9EIKAe+7/MnPgVYztqjU5c4="
  else
    "sha256-d8YeLD/BQAB6IC4jvBke9EIKAe+7/MnPgVYztqjU5c4=";

in with lib;
buildGoModule rec {
  pname = "mcchunkie";
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "qbit";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-UNPv9QXFJeNx+3RleseNVSKBZGNc3eiMsEKnfIVyoeA=";
  };

  vendorSha256 = vendorHash;

  ldflags = [ "-X suah.dev/mcchunkie/plugins.version=${version}" ];

  proxyVendor = true;

  doCheck = false;

  meta = {
    description = "Matrix Bot";
    homepage = "https://github.com/qbit/mcchunkie";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
