{ lib
, buildGoModule
, fetchFromGitHub
, ...
}:
with lib;
buildGoModule rec {
  pname = "yarr";
  version = "2.4";

  src = fetchFromGitHub {
    owner = "nkanaev";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-ZMQ+IX8dZuxyxQhD/eWAe4bGGCVcaCeVgF+Wqs79G+k=";
  };

  vendorHash = null;

  ldflags = [ "-X main.Version=${version}" ];

  tags = [ "sqlite_foreign_keys" "release" ];

  proxyVendor = true;

  doCheck = false;

  subPackages = [ "./src/main.go" ];

  postInstall = ''
    mv $out/bin/main $out/bin/yarr
  '';

  meta = {
    description = "Yet Another RSS Reader";
    homepage = "https://github.com/nkanaev/yarr";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
