{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:
with lib;
  buildGoModule rec {
    pname = "sliding-sync";
    version = "0.99.6";

    src = fetchFromGitHub {
      owner = "matrix-org";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-t0TlmoqXaKR5PrR0vlsLU84yBdXPXmE63n6p4sMvHhs=";
    };

    vendorHash = "sha256-9bJ6B9/jq7q5oJGULRPoNVJiqoO+2E2QQKORy4rt6Xw=";

    # Note: tests require a postgres install accessible to the current user
    doCheck = false;

    meta = {
      description = "An implementation of MSC3575";
      homepage = "https://github.com/matrix-org/sliding-sync";
      license = licenses.asl20;
      maintainers = with maintainers; [qbit];
    };
  }
