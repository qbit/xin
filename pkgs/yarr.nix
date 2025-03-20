{ lib
, buildGoModule
, fetchFromGitHub
, ...
}:
with lib;
buildGoModule rec {
  pname = "yarr";
  version = "unstable-2025-03-19";

  src = fetchFromGitHub {
    owner = "nkanaev";
    repo = pname;
    rev = "35850d6310d0bb4e1e71f6b1aa92d0acb33d057c";
    sha256 = "sha256-BqcgN56zYle/861j8R8j1cLOm/9R3YbQR6lRL2zGge4=";
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
