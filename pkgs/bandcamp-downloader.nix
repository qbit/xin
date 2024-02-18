{
  lib,
  beautifulsoup4,
  browser-cookie3,
  buildPythonPackage,
  certifi,
  charset-normalizer,
  cryptography,
  fetchFromGitHub,
  idna,
  importlib-metadata,
  jaraco_classes,
  jeepney,
  keyring,
  lz4,
  more-itertools,
  pbkdf2,
  poetry-core,
  pyaes,
  pycparser,
  pycryptodome,
  requests,
  secretstorage,
  setuptools,
  soupsieve,
  tqdm,
  urllib3,
  zipp,
  ...
}:
buildPythonPackage rec {
  pname = "bandcamp-downloader";
  version = "unstable-2023-09-22";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "easlice";
    repo = pname;
    rev = "871cedf285a8e8a60b156086ad3222ce49e90c7f";
    hash = "sha256-hCQhzxuSqAQhEAmev+bTfMykFKaOItx/iLxaghLl79M=";
  };

  propagatedBuildInputs = [
    beautifulsoup4
    browser-cookie3
    certifi
    charset-normalizer
    cryptography
    idna
    importlib-metadata
    jaraco_classes
    jeepney
    keyring
    lz4
    more-itertools
    pbkdf2
    poetry-core
    pyaes
    pycparser
    pycryptodome
    requests
    secretstorage
    setuptools
    soupsieve
    tqdm
    urllib3
    zipp
  ];
  #nativeBuildInputs = [ setuptools-scm ];

  #doCheck = false;

  #pythonImportsCheck = [ "dataset" ];

  meta = with lib; {
    description = "Download your bandcamp collection";
    homepage = "https://github.com/easlice/bandcamp-downloader";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
    mainProgram = "bandcamp-downloader.py";
  };
}
