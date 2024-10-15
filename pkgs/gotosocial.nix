{ lib
, buildGoModule
, fetchFromGitHub
, go
, ffmpeg
, ...
}:
let
  gotosocialVersion = "0.17.0";
  gtswaHash = "sha256:1i6ks3dlmaq9g8a1fka26fgrcy9ps0kxmyvqhzjdkabwzwhqyah1";
  gtssHash = "sha256-uyqP3zhjcXKejGFAwZoTn2kY8IpX0QAAXNzb1VG6ve8=";
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
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ qbit ];
  };
}
