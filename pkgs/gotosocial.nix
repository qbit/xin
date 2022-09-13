{ stdenv, lib, buildGoModule, fetchFromGitHub, makeWrapper, go, git, ... }:
let
  gotosocialVersion = "0.5.0-rc1";
  gotosocialWebAssets = builtins.fetchurl {
    url =
      "https://github.com/superseriousbusiness/gotosocial/releases/download/v${gotosocialVersion}/gotosocial_${gotosocialVersion}_web-assets.tar.gz";
    sha256 = "sha256-jmciiSRW73aoZu8WCVpEpMR0xemJUQ12h7ZUFFqmmko=";
  };
in with lib;
buildGoModule rec {
  pname = "gotosocial";
  version = gotosocialVersion;

  src = fetchFromGitHub {
    owner = "superseriousbusiness";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-xq+hebQaJZ1C2Tgc9MwWf8fYTpSu8B6EZMC8CKB2nu0=";
  };

  doCheck = false;

  #ldflags = [ "-X github.com/gomods/athens/pkg/build.version=${version}" ];

  #nativeBuildInputs = lib.optionals stdenv.isLinux [ makeWrapper go ];

  proxyVendor = false;

  #subPackages = [ "cmd/proxy" ];

  vendorSha256 = null;

  postInstall = ''
    mkdir -p $out/assets
    tar -C $out/assets/ -zxvf ${gotosocialWebAssets}
  '';

  meta = {
    description = "Fast, fun, ActivityPub server, powered by Go.";
    homepage = "https://github.com/superseriousbusiness/gotosocial";
    license = licenses.agpl3;
    maintainers = with maintainers; [ qbit ];
  };
}
