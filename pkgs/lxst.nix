{ lib
, buildPythonPackage
, fetchFromGitHub
, soundcard
, numpy
, codec2
, pyogg
, cython
, rns
, ffmpeg
, setuptools
, libopus
, setuptools-scm
, ...
}:
let
  pycodec2 = buildPythonPackage rec {
    pname = "pycodec2";
    version = "4.0.0";

    pyproject = true;

    src = fetchFromGitHub {
      owner = "gregorias";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-5BEJ8q+Onh3eITSmEk2PoNrVViVISULZsiI2cCl24b0=";
    };
    nativeBuildInputs = [
      setuptools-scm
      setuptools
    ];
    propagatedBuildInputs = [
      cython
      numpy
      pyogg
    ];
    buildInputs = [
      codec2
      libopus
    ];
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail "numpy==2.1.*" "numpy"
    '';
  };
in
buildPythonPackage rec {
  pname = "lxst";
  version = "unstable-2025-03-11";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "markqvist";
    repo = pname;
    rev = "94814f1c31f743da7381e73dc1d7463c9882fae7";
    hash = "sha256-D33OYbTa5iuJo9s/NYr5oYc+UlRjhANyKUK6g998P08=";
  };

  #SETUPTOOLS_SCM_PRETEND_VERSION = version;

  doCheck = true;

  nativeBuildInputs = [
    setuptools-scm
    setuptools
  ];

  propagatedBuildInputs = [
    soundcard
    numpy
    pycodec2
    ffmpeg
    rns
  ];


  meta = with lib; {
    homepage = "https://github.com/markqvist/LXST";
    description = "lxst";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
