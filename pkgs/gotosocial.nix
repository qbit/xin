{
  lib,
  buildGoModule,
  fetchFromGitHub,
  go,
  ffmpeg,
  ...
}: let
  gotosocialVersion = "0.11.0-rc2";
  gtswaHash = "sha256:06cy07xycs605c7hgilj427pg6jg29vi11f048795fzjcrrl4r6z";
  gtssHash = "sha256-HYUqIyAxcd4pMjMcSHdR75XT/llEACNVMEljSYz9104=";
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
