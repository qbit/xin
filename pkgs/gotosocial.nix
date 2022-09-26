{ stdenv, lib, buildGoModule, fetchFromGitHub, makeWrapper, go, git, ffmpeg, ...
}:
let
  gotosocialVersion = "0.5.0-rc3";
  gotosocialWebAssets = builtins.fetchurl {
    url =
      "https://github.com/superseriousbusiness/gotosocial/releases/download/v${gotosocialVersion}/gotosocial_${gotosocialVersion}_web-assets.tar.gz";
    sha256 = "sha256:1m8vwhwfi2n2w0vyqgf81k4qmj3fi48sah61bik3yd39n2pybcr5";
  };
in with lib;
buildGoModule rec {
  pname = "gotosocial";
  version = gotosocialVersion;

  src = fetchFromGitHub {
    owner = "superseriousbusiness";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-4L6TkKrHBq33Yu7a/lJ7NaXxHjlz7ymBXKfDUtvLHkI=";
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
