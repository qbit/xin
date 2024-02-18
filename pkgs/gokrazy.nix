{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:
with lib;
buildGoModule {
  pname = "gokrazy";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "gokrazy";
    repo = "tools";
    rev = "b89d9dc6e09742ea23492bb84021da70b2965bff";
    sha256 = "sha256-1nWpLQMDvtV83HFvmrNdN31DVENq3HUqk/6+zuavoTU=";
  };

  vendorHash = "sha256-d6je2aRHlgP4r/Yg55zezRMTul1p5aLEpxfLb3V6BFg=";

  proxyVendor = true;

  doCheck = false;

  meta = {
    description = "CLI tools for gokrazy";
    homepage = "https://github.com/gokrazy/tools";
    license = licenses.bsd3;
    maintainers = with maintainers; [ qbit ];
  };
}
