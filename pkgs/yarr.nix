{ lib
, buildGoModule
, fetchFromGitHub
, ...
}:
with lib;
buildGoModule rec {
  pname = "yarr";
  version = "unstable-2024-11-28";

  src = fetchFromGitHub {
    owner = "nkanaev";
    repo = pname;
    rev = "321ad7608fbb3368b6c89b2e9bfa07a4eb3bdc40";
    sha256 = "sha256-ZX9qs8zAbEiFcq0YVwM3TiUWTcx+N63HV83JI8iGdrA=";
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
