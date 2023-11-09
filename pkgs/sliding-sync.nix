{ lib
, buildGoModule
, fetchFromGitHub
, ...
}:
with lib;
buildGoModule rec {
  pname = "sliding-sync";
  version = "0.99.12";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-7M+Ti1SfurRngXg2oCdLveG6QyjM2BjKnoovJxz7ZOY=";
  };

  vendorHash = "sha256-li5kEF7U7KyyMLMhVBqvnLuLXI6QrJl1KeusKrQXo8w=";

  # Note: tests require a postgres install accessible to the current user
  doCheck = false;

  meta = {
    description = "An implementation of MSC3575";
    homepage = "https://github.com/matrix-org/sliding-sync";
    license = licenses.asl20;
    maintainers = with maintainers; [ qbit ];
  };
}
