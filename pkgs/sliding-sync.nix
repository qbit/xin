{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:
with lib;
  buildGoModule rec {
    pname = "sliding-sync";
    version = "0.99.10";

    src = fetchFromGitHub {
      owner = "matrix-org";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-TjChelGVicA59q6iIIDTI7nSj8KtjpA4bfZqsfoiOQg=";
    };

    vendorHash = "sha256-E3nCcw6eTKKcL55ls6n5pYlRFffsefsN0G1Hwd49uh8=";

    # Note: tests require a postgres install accessible to the current user
    doCheck = false;

    meta = {
      description = "An implementation of MSC3575";
      homepage = "https://github.com/matrix-org/sliding-sync";
      license = licenses.asl20;
      maintainers = with maintainers; [qbit];
    };
  }
