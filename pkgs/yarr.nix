{ lib, buildGoModule, fetchFromGitHub, ... }:

with lib;
buildGoModule rec {
  pname = "yarr";
  version = "2.3";

  src = fetchFromGitHub {
    owner = "nkanaev";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-LW0crWdxS6zcY5rxR0F2FLDYy9Ph2ZKyB/5VFVss+tA=";
  };

  vendorSha256 = "sha256-dseEvPu7VapyPzGKjqlFfXeaJdRF19YxCfZVn+ePYBc=";

  ldflags = [ "-X main.Version=${version}" ];

  tags = [ "sqlite_foreign_keys" "release" ];

  proxyVendor = true;

  patches = [ ./yarr_manifest.diff ];

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
