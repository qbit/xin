{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  beautifulsoup4,
  fastapi,
  httptools,
  logzero,
  lxml,
  mistletoe,
  more-itertools,
  mypy,
  pytz,
  setuptools,
  tzlocal,
  urlextract,
  uvicorn,
  uvloop,
  watchfiles,
  websockets,
  setuptools-scm,
  starlette,
  pkgs,
  ...
}:
with pkgs;
let
  hpi = pkgs.python3Packages.callPackage ./hpi.nix { inherit pkgs; };
  sqlcipher3 = pkgs.python3Packages.callPackage ./sqlcipher3.nix { inherit pkgs; };
  cachew = pkgs.python3Packages.callPackage ./cachew.nix { inherit pkgs; };
  python-dotenv = pkgs.python3Packages.callPackage ./python-dotenv.nix { };
in
buildPythonPackage rec {
  pname = "promnesia";
  version = "1.1.20231016";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "karlicoss";
    repo = pname;
    rev = "9ff734e6fde9ee42f9e8f895d1de54ee02e95d78";
    hash = "sha256-TmLyHqa25I6NoTPsmd1AesYdxc8hmGPHdiMuFfw78uQ=";
  };

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  doCheck = true;

  nativeBuildInputs = [ setuptools-scm ];

  # Optional
  # bs4 lxml mistletoe logzero
  propagatedBuildInputs = [
    beautifulsoup4
    cachew
    fastapi
    hpi
    httptools
    starlette
    logzero
    lxml
    mistletoe
    more-itertools
    mypy
    python-dotenv
    pytz
    setuptools
    sqlcipher3
    tzlocal
    urlextract
    uvicorn
    uvloop
    watchfiles
    websockets
  ];

  makeWrapperArgs = [
    # Add the installed directories to the python path so the daemon can find them
    "--prefix PYTHONPATH : ${python3.pkgs.makePythonPath propagatedBuildInputs}"
    "--prefix PYTHONPATH : $out/lib/${python3.libPrefix}/site-packages"
  ];

  meta = with lib; {
    homepage = "https://github.com/karlicoss/promnesia";
    description = "Another piece of your extended mind";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
