{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:
with lib;
buildGoModule rec {
  pname = "gosignify";
  version = "0.0.0-20210702013543-c91e79d30e91";

  src = fetchFromGitHub {
    owner = "frankbraun";
    repo = pname;
    rev = "c91e79d30e9115216a827222e07f44e9c4339ed2";
    sha256 = "sha256-Ynmx6NUUQ5WEYFowuW/ELjV2ESOHqoOTVqdZ6CWt6LQ=";
  };

  proxyVendor = false;

  vendorHash = null;

  meta = {
    description = "gosignify is a Go reimplementation of OpenBSD's signify";
    homepage = "https://github.com/frankbraun/gosignify";
    license = licenses.unlicense;
    maintainers = with maintainers; [ qbit ];
  };
}
