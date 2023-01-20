{ pkgs, lib, buildGoModule, fetchFromGitHub, ... }:
with lib;
with pkgs;
buildGoModule rec {
  pname = "tailscale-systray";
  version = "2022-10-19";

  src = fetchFromGitHub {
    owner = "mattn";
    repo = pname;
    rev = "e7f8893684e7b8779f34045ca90e5abe6df6056d";
    sha256 = "sha256-3kozp6jq0xGllxoK2lGCNUahy/FvXyq11vNSxfDehKE=";
  };

  vendorSha256 = "sha256-YJ74SeZAMS+dXyoPhPTJ3L+5uL5bF8gumhMOqfvmlms=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libayatana-appindicator gtk3 ];

  proxyVendor = true;

  meta = {
    description = "Tailscale systray";
    homepage = "https://github.com/mattn/tailscale-systray";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
