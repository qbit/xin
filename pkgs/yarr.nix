{ lib, buildGoModule, fetchFromGitHub, ... }:

with lib;
buildGoModule rec {
  pname = "yarr";
  version = "2023-01-30";

  src = fetchFromGitHub {
    owner = "nkanaev";
    repo = pname;
    #rev = "v${version}";
    rev = "c092842ee4a9621aff12d439f2fedd95058010fe";
    sha256 = "sha256-VTEe+7x6DVXJFS+AEnfcUaag85zzK5Xve0zp1Polw7I=";
  };

  vendorSha256 = null;

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
