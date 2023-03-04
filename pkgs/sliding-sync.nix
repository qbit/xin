{ lib, buildGoModule, fetchFromGitHub, ... }:
with lib;
buildGoModule rec {
  pname = "sliding-sync";
  version = "0.99.1";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-g1yMGb8taToEFG6N057yPcdZB855r0f6EwnJ98FIiic=";
  };

  vendorHash = "sha256-FmibAVjKeJUrMSlhoE7onLoa4EVjQvjDI4oU4PB5LBE=";

  # Note: tests require a postgres install accessible to the current user
  doCheck = false;

  meta = {
    description = "An implementation of MSC3575";
    homepage = "https://github.com/matrix-org/sliding-sync";
    license = licenses.asl20;
    maintainers = with maintainers; [ qbit ];
  };
}
