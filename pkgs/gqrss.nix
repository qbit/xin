{ lib, buildGoModule, fetchFromGitHub, isUnstable, ... }:

let
  vendorHash = if isUnstable then
    ""
  else
    "sha256-NIAJKq7TiMessqaohkdHy+j/vBKvMsiPgmnaiNAsGeE=";

in with lib;
buildGoModule rec {
  pname = "gqrss";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "qbit";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-1ZGjifDgqA9yk9l0YB4rLpcvwaq9lWxDgItJ7lCVj2I=";
  };

  vendorSha256 = vendorHash;

  proxyVendor = true;

  doCheck = false;

  meta = {
    description = "Simple github query tool";
    homepage = "https://github.com/qbit/gqrss";
    license = licenses.isc;
    maintainers = with maintainers; [ qbit ];
  };
}
