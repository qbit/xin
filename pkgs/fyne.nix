{ lib
, buildGoModule
, fetchFromGitHub
, ...
}:
with lib;
buildGoModule rec {
  pname = "fyne";
  version = "2.3.5";

  src = fetchFromGitHub {
    owner = "fyne-io";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-iSQ1oqUePxDyjQTKNazX0IZyHAoz50bqukV2CmQjrAk=";
  };

  vendorHash = null;

  proxyVendor = true;

  subPackages = [ "cmd/fyne" ];

  meta = {
    description = "Fyne command line tool";
    homepage = "https://github.com/fyne-io/fyne";
    license = licenses.bsd3;
    maintainers = with maintainers; [ qbit ];
  };
}
