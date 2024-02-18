{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:
let
  vendorHash = "sha256-1zBZREClt8jy0TUXJ1FuBEAJEPQoUcl4DZZ6U2LtRzg=";
in
with lib;
buildGoModule rec {
  pname = "gqrss";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "qbit";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-1ZGjifDgqA9yk9l0YB4rLpcvwaq9lWxDgItJ7lCVj2I=";
  };

  inherit vendorHash;

  proxyVendor = true;

  doCheck = false;

  meta = {
    description = "Simple github query tool";
    homepage = "https://github.com/qbit/gqrss";
    license = licenses.isc;
    maintainers = with maintainers; [ qbit ];
  };
}
