{ stdenv, lib, buildGo119Module, fetchFromGitHub, makeWrapper, go, git, ffmpeg
, ... }:
let
  gotosocialVersion = "0.6.0";
  gotosocialWebAssets = builtins.fetchurl {
    url =
      "https://github.com/superseriousbusiness/gotosocial/releases/download/v${gotosocialVersion}/gotosocial_${gotosocialVersion}_web-assets.tar.gz";
    sha256 = "sha256:17sfny68wx3a16sl1fkfxvr7225nyaf0d4r4gw1phis65l7cj1s4";
  };
in with lib;
buildGo119Module rec {
  pname = "gotosocial";
  version = gotosocialVersion;

  src = fetchFromGitHub {
    owner = "superseriousbusiness";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-VL0B+8n5mmr1qd5hSdURmaNxqnSaUynGu1qsXo/D+dQ=";
  };

  ldflags = [
    "-s"
    "-w"
    "-extldflags '-static'"
    "-X 'main.Commit=${version}'"
    "-X 'main.Version=${version}'"
  ];

  propagatedBuildInputs = [ ffmpeg ];

  proxyVendor = false;

  vendorSha256 = null;

  doCheck = false;

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
