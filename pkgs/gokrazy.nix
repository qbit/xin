{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:
with lib;
buildGoModule {
  pname = "gokrazy";
  version = "2023-12-22";

  src = fetchFromGitHub {
    owner = "gokrazy";
    repo = "tools";
    rev = "80a59f115332a41206487afc6038beaaed48ce70";
    sha256 = "sha256-YOo2VhidMbc5Cmc3YHx4hb/vlbnXeyrWWGxuSJPdX/o=";
  };

  vendorHash = "sha256-BJTEP9n9oJcW2m5UAeExg3ydi+k9w4e+XLmxj/wGAl0=";

  proxyVendor = true;

  doCheck = false;

  meta = {
    description = "CLI tools for gokrazy";
    homepage = "https://github.com/gokrazy/tools";
    license = licenses.bsd3;
    maintainers = with maintainers; [ qbit ];
  };
}
