{ lib, buildGoModule, fetchFromGitHub, ... }:

with lib;
buildGoModule rec {
  pname = "yarr";
  version = "2023-03-18";

  src = fetchFromGitHub {
    owner = "nkanaev";
    repo = pname;
    #rev = "v${version}";
    rev = "d2678be96d37a71ec34ac23207393f78dcceafc5";
    sha256 = "sha256-BCP2d4Fk5KkWz7tmx7kMybnRZEGHIRjtNiNIpNCXRYE=";
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
