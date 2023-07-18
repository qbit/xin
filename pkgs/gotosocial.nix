{
  lib,
  buildGo119Module,
  fetchFromGitHub,
  go,
  ffmpeg,
  ...
}: let
  gotosocialVersion = "0.10.0-rc3";
  gtswaHash = "sha256:1pnnpbxz4b1gy194sw4yvxalk6ym04ha978w3hjz4shvymq3qnw4";
  gtssHash = "sha256-Up9TXSm1fQTQ4s/9WQLaelVsSqH93ljNuWx6aEIrI3I=";
  gotosocialWebAssets = builtins.fetchurl {
    url = "https://github.com/superseriousbusiness/gotosocial/releases/download/v${gotosocialVersion}/gotosocial_${gotosocialVersion}_web-assets.tar.gz";
    sha256 = gtswaHash;
  };
in
  with lib;
    buildGo119Module rec {
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

      propagatedBuildInputs = [ffmpeg];

      proxyVendor = false;

      vendorSha256 = null;

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
        maintainers = with maintainers; [qbit];
      };
    }
