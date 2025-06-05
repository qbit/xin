{
  pkgs,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools-scm,
  beautifulsoup4,
  click,
  ipython,
  logzero,
  lxml,
  platformdirs,
  pytz,
}:
let
  cachew = pkgs.python3Packages.callPackage ./cachew.nix { inherit pkgs; };
in
buildPythonPackage rec {
  pname = "google_takeout_parser";
  version = "0.0.20240508";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "seanbreckenridge";
    repo = pname;
    rev = "9aea89ffeae29246c9c6e27a62dd9fad13b17abc";
    hash = "sha256-ns3vBnsZVyUi2nnnE3cBZ7vzZQQ44gkfvglkMZGuud0=";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  doCheck = true;

  nativeBuildInputs = [
    setuptools-scm
  ];

  propagatedBuildInputs = [
    beautifulsoup4
    cachew
    click
    ipython
    logzero
    lxml
    platformdirs
    pytz
  ];
}
