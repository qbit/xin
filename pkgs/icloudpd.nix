{ pkgs, lib, stdenv, fetchFromGitHub, buildPythonPackage, python3Packages }:
let mydateutil = buildPythonPackage rec {
  pname = "python-dateutil";
  version = "2.8.1";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-c+v+nb8i6DIoba+mBHPkzSOfhZL2mapa2vEAUObhgjw=";
  };

  nativeBuildInputs = with pkgs.python3Packages; [ setuptools-scm ];

  propagatedBuildInputs = with pkgs.python3Packages; [ six ];

  # cyclic dependency: tests need freezegun, which depends on python-dateutil
  doCheck = false;
};
myclick =   buildPythonPackage rec {
  pname = "click";
  version = "6.7";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-8VUW30eNWlYYD7+A5o8gYBDm0WD8OfpQi2XgNf11Ews=";
  };

  doCheck = false;
};
mytoml =   buildPythonPackage rec {
  pname = "toml";
  version = "3.4";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "";
  };

  doCheck = false;
};
mytqdm =   buildPythonPackage rec {
  pname = "tqdm";
  version = "4.56.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-/j0I3QClJoUFaNVC/53pu8Kgmnkdo8M08yE9jQu7ymU=";
  };


  doCheck = false;
};
mykeyring =   buildPythonPackage rec {
  pname = "keyring";
  version = "8.7";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-3X3Y+dwkq/fa6WVb7tbS4fcgsP8Y/SkoR+eaLmLNAhE=";
  };

  doCheck = false;
};
myicipd =   buildPythonPackage {
  pname = "pyicloud_ipd";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "icloud-photos-downloader";
    repo = "pyicloud";
    rev = "d1153d0424e4788604ab577bd44f763d835dddd5";
    sha256 = "sha256-yYhZ0pS3qSVoyxiRjD1lU5VD05MhWo7hcLEzs8eyk2M=";
  };

  propagatedBuildInputs = with python3Packages; [ myclick mykeyring ];

  doCheck = false;
};

in buildPythonPackage  {
  pname = "icloudpd";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "icloud-photos-downloader";
    repo = "icloud_photos_downloader";
    rev = "d1644ad0f3c22118509e9b834e54148733122f7b";
    hash = "sha256-r0UXmi5MZCf3TCy8LK1HoEt3tSLxQ0fgXuD/LvLV8j4=";
  };

  propagatedBuildInputs = with python3Packages; [ requests schema mydateutil myclick myicipd ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/icloud-photos-downloader/icloud_photos_downloader";
    description = "A command-line tool to download photos from iCloud";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
