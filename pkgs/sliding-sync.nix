{ lib
, buildGoModule
, fetchFromGitHub
, ...
}:
with lib;
buildGoModule rec {
  pname = "sliding-sync";
  version = "0.99.19";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-w4VL+MioNeJ/R48Ln9tYaqlfg7NvT3mQs0dWOZTHQK4=";
  };

  vendorHash = "sha256-THjvc0TepIBFOTte7t63Dmadf3HMuZ9m0YzQMI5e5Pw=";

  # Note: tests require a postgres install accessible to the current user
  doCheck = false;

  meta = {
    description = "An implementation of MSC3575";
    homepage = "https://github.com/matrix-org/sliding-sync";
    license = licenses.asl20;
    maintainers = with maintainers; [ qbit ];
  };
}
