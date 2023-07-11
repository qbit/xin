{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:
with lib;
  buildGoModule rec {
    pname = "sliding-sync";
    version = "0.99.3";

    src = fetchFromGitHub {
      owner = "matrix-org";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-lmmOq0gkvrIXQmy3rbTga0cC85t0LWjDOqrH1NWUpdA=";
    };

    vendorHash = "sha256-447P2TbBUEHmHubHiiZCrFVCj2/tmEuYFzLo27UyCk4=";

    # Note: tests require a postgres install accessible to the current user
    doCheck = false;

    meta = {
      description = "An implementation of MSC3575";
      homepage = "https://github.com/matrix-org/sliding-sync";
      license = licenses.asl20;
      maintainers = with maintainers; [qbit];
    };
  }
