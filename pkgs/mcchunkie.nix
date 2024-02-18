{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:
with lib;
buildGoModule rec {
  pname = "mcchunkie";
  version = "1.0.14";

  src = fetchFromGitHub {
    owner = "qbit";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-biKmKulVV4ed0x/3KLESNDXBkihk7OlPcQPeAZmVNPU=";
  };

  vendorHash = "sha256-OGSJeyGxXdKCD7nNRsJcKEKqBQOBKEc6RdtJfoIgR+0=";

  ldflags = [ "-X suah.dev/mcchunkie/plugins.version=${version}" ];

  proxyVendor = true;

  doCheck = false;

  meta = {
    description = "Matrix Bot";
    homepage = "https://github.com/qbit/mcchunkie";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
