{ lib, buildGoModule, fetchFromGitHub, ... }:

with lib;
buildGoModule rec {
  pname = "yarr";
  version = "2023-05-16";

  src = fetchFromGitHub {
    owner = "nkanaev";
    repo = pname;
    #rev = "v${version}";
    rev = "7d99edab8d3c054e75feba183bd76fead15712f1";
    sha256 = "sha256-gOydL1SyM1bGbErpefWlwhjLWH6j0GGpI/F0kEBHxic=";
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
