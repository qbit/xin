{ lib
, buildGoModule
, fetchFromGitHub
, go
, ffmpeg
, ...
}:
let
  gotosocialVersion = "0.13.0-rc2";
  gtswaHash = "sha256:0vimnzn8sps6n7fwvjdplvs0gw3b6dkd2dyq4k06175favcx3m04";
  gtssHash = "sha256-f1aU29S9JiAkMUfAXJnzddHAS6bE4YFRfvwWg6exFo0=";
  gotosocialWebAssets = builtins.fetchurl {
    url = "https://github.com/superseriousbusiness/gotosocial/releases/download/v${gotosocialVersion}/gotosocial_${gotosocialVersion}_web-assets.tar.gz";
    sha256 = gtswaHash;
  };
in
with lib;
buildGoModule rec {
  pname = "gotosocial";
  version = gotosocialVersion;

  src = fetchFromGitHub {
    owner = "superseriousbusiness";
    repo = pname;
    rev = "v${version}";
    hash = gtssHash;
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

  vendorHash = null;

  doCheck = false;

  preBuild = ''
    echo ${go}/bin/go
    ${go}/bin/go version
  '';

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
