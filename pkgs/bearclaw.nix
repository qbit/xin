{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:
with lib;
  buildGoModule rec {
    pname = "bearclaw";
    version = "1.1.0";

    src = fetchFromGitHub {
      owner = "donuts-are-good";
      repo = pname;
      rev = "${version}";
      sha256 = "sha256-AhqW+AAEBbAPJO0hnZnC5a/u4IKyLII6OWYEQzoX0C8=";
    };

    vendorSha256 = "sha256-7XFvghT411YE+Y9bYEFOKR655EaFS4GZiDzUYiYRbMY=";

    meta = {
      description = "tiny static site generator";
      homepage = "https://github.com/donuts-are-good/bearclaw";
      license = licenses.mit;
      maintainers = with maintainers; [qbit];
    };
  }
