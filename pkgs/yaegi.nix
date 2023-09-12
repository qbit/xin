{ lib
, buildGoModule
, fetchFromGitHub
, ...
}:
with lib;
buildGoModule rec {
  pname = "yaegi";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "traefik";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-++WA6Xdo9YuMQgCL/c485LgKeV4XeodVZBBYCBsmh+M=";
  };

  vendorHash = null;

  meta = {
    description = "Yaegi is Another Elegant Go Interpreter";
    homepage = "https://github.com/traefik/yaegi";
    license = licenses.asl20;
    maintainers = with maintainers; [ qbit ];
  };
}
