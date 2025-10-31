{
  lib,
  buildGoModule,
  fetchgit,
  ...
}:
with lib;
buildGoModule {
  pname = "blurp";
  version = "2025-04-29";

  src = fetchgit {
    url = "https://git.coopcloud.tech/decentral1se/blurp.git";
    rev = "6d3e7138361505b2bfe42e9bc269dfbe7f365b31";
    hash = "sha256-pJqq8Afdazu9vnAeWoZclQy572nCmxrdMuwbId5mX60=";
  };

  vendorHash = null;
  proxyVendor = true;

  meta = {
    description = "GTS status management tool";
    maintainers = with maintainers; [ qbit ];
  };
}
