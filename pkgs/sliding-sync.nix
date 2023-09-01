{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:
with lib;
  buildGoModule rec {
    pname = "sliding-sync";
    version = "0.99.8";

    src = fetchFromGitHub {
      owner = "matrix-org";
      repo = pname;
      rev = "8e096656f58ffdc15ac5b08fc088eee1187a4a99";
      hash = "sha256-4rYLHUlHbQ6KnxyXCCLqG4/zfXdZm4KZX1cOg5ITQPk=";
    };

    vendorHash = "sha256-JYSpjAgIvQFpYmOTifRXHVB6bSrukqSVhmAAmHylPbQ=";

    # Note: tests require a postgres install accessible to the current user
    doCheck = false;

    meta = {
      description = "An implementation of MSC3575";
      homepage = "https://github.com/matrix-org/sliding-sync";
      license = licenses.asl20;
      maintainers = with maintainers; [qbit];
    };
  }
