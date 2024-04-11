{ lib
, buildGoModule
, fetchFromGitHub
, go
, ffmpeg
, ...
}:
let
  gotosocialVersion = "0.15.0";
  gtswaHash = "sha256:0kia1dmd7gc4a7r1hav6ipjbrjzwdkyvwvfczbxghwa1hwa9vd5y";
  gtssHash = "sha256-z0iETddkw4C2R6ig9ZO8MTvhuWnmQ37/6q3oZ4WAzd4=";
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
