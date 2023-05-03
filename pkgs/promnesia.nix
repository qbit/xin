{ lib, buildPythonPackage, fetchFromGitHub, beautifulsoup4, fastapi, httptools
, logzero, lxml, mistletoe, more-itertools, mypy, pytz, setuptools, tzlocal
, urlextract, uvicorn, uvloop, watchfiles, websockets, setuptools-scm, pkgs, ...
}:
with pkgs;
let
  hpi = pkgs.python3Packages.callPackage ./hpi.nix { inherit pkgs; };
  sqlcipher3 =
    pkgs.python3Packages.callPackage ./sqlcipher3.nix { inherit pkgs; };
  cachew = pkgs.python3Packages.callPackage ./cachew.nix { inherit pkgs; };
  python-dotenv = pkgs.python3Packages.callPackage ./python-dotenv.nix { };
in buildPythonPackage rec {
  pname = "promnesia";
  version = "1.1.20230417";

  src = fetchFromGitHub {
    owner = "karlicoss";
    repo = pname;
    rev = "1f60af17761570b8a6787ebf0753ecfa750cad1b";
    hash = "sha256-iaMoNEz3bNNEH+K2vXu21T+JLQVGC7iq3PBjm4Vv+24=";
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
