{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:
with lib;
  buildGoModule rec {
    pname = "mcchunkie";
    version = "1.0.13";

    src = fetchFromGitHub {
      owner = "qbit";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-/vPiwrNSdGDZtnnZTCxrkvRLP45c/c2/rYhBQNsddsg=";
    };

    vendorHash = "sha256-OWIjq8Qsr1UEOrdDZlYG6qlVKs51R6xNhCqXSqAE2Mk=";

    ldflags = ["-X suah.dev/mcchunkie/plugins.version=${version}"];

    proxyVendor = true;

    doCheck = false;

    meta = {
      description = "Matrix Bot";
      homepage = "https://github.com/qbit/mcchunkie";
      license = licenses.mit;
      maintainers = with maintainers; [qbit];
    };
  }
