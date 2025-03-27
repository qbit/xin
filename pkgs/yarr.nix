{ lib
, buildGoModule
, fetchFromGitHub
, ...
}:
with lib;
buildGoModule rec {
  pname = "yarr";
  version = "2.5";

  src = fetchFromGitHub {
    owner = "nkanaev";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-yII0KV4AKIS1Tfhvj588O631JDArnr0/30rNynTSwzk=";
  };

  vendorHash = null;

  ldflags = [ "-X main.Version=${version}" ];

  tags = [ "sqlite_foreign_keys" "release" ];

  proxyVendor = true;

  doCheck = false;

  meta = {
    description = "Yet Another RSS Reader";
    homepage = "https://github.com/nkanaev/yarr";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
