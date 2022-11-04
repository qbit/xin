{ lib, buildGoModule, fetchFromGitHub, isUnstable, ... }:
let
  vendorHash = if isUnstable then
    "sha256-GCQckQe9Y96upJX2X9RDXoQIyH/SD9CniPVsIbdAPmM="
  else
    "sha256-3xIIb+fzbTOq9jf0STL3W9re5yH0JN4RO9dd/Ic1aIg=";
    in with lib;
buildGoModule rec {
  pname = "mcchunkie";
  version = "1.0.11";

  src = fetchFromGitHub {
    owner = "qbit";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-SZx5h+RWgG1tq4kLZ4lh4jlPjprz3Gp3gPLfb/7cNzQ=";
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
