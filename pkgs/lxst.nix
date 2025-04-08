{ lib
, buildPythonPackage
, fetchFromGitHub
, codec2
, cython
, ffmpeg
, libopus
, numpy
, pydub
, pytestCheckHook
, rns
, setuptools
, setuptools-scm
, soundcard
, pkgs
, ...
}:
let
  pyogg = pkgs.python3Packages.pyogg.overridePythonAttrs (_: {
    version = "unstable-2024-09-13";
    patchFlags = [
      "--binary"
      "-p1"
      "--ignore-whitespace"
    ];
    patches = with pkgs; [
      (substituteAll {
        src = ./pyogg-paths.patch;
        flacLibPath = "${flac.out}/lib/libFLAC${stdenv.hostPlatform.extensions.sharedLibrary}";
        oggLibPath = "${libogg}/lib/libogg${stdenv.hostPlatform.extensions.sharedLibrary}";
        vorbisLibPath = "${libvorbis}/lib/libvorbis${stdenv.hostPlatform.extensions.sharedLibrary}";
        vorbisFileLibPath = "${libvorbis}/lib/libvorbisfile${stdenv.hostPlatform.extensions.sharedLibrary}";
        vorbisEncLibPath = "${libvorbis}/lib/libvorbisenc${stdenv.hostPlatform.extensions.sharedLibrary}";
        opusLibPath = "${libopus}/lib/libopus${stdenv.hostPlatform.extensions.sharedLibrary}";
        opusFileLibPath = "${opusfile}/lib/libopusfile${stdenv.hostPlatform.extensions.sharedLibrary}";
      })
    ];
    src = pkgs.fetchFromGitHub {
      owner = "TeamPyOgg";
      repo = "PyOgg";
      rev = "4118fc40067eb475468726c6bccf1242abfc24fc";
      hash = "sha256-th+qHKcDur9u4DBDD37WY62o5LR9ZUDVEFl+m7aXzNY=";
    };
  });

  myrns =
    if pkgs.python3Packages.rns.version == "0.9.2" then
      pkgs.python3Packages.rns.overridePythonAttrs
        (_: {
          version = "0.9.3";
          src = fetchFromGitHub {
            owner = "markqvist";
            repo = "Reticulum";
            tag = "0.9.3";
            hash = "sha256-50L+5WVsYaidz71rkGZny2KlCR3ZfPEQJEPI38MOBWA=";
          };
        }) else pkgs.python3Packages.rns;

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

    build-system = [
      cython
      numpy
      setuptools
    ];

    buildInputs = [
      codec2
      libopus
    ];

    dependencies = [
      numpy
    ];

    pythonImportsCheck = [ "pycodec2" ];

    nativeCheckInputs = [
      pytestCheckHook
    ];

    preCheck = ''
      rm -rf pycodec2
    '';
    doCheck = false;

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
    rev = "846c7487a1313a3033a3dc2abd5b7056e809866a";
    hash = "sha256-XX1l1PNg97deB06FtJ/QBzQM/xPLWQPAyycRvIE28B0=";
  };

  #SETUPTOOLS_SCM_PRETEND_VERSION = version;

  doCheck = true;

  nativeBuildInputs = [
    setuptools-scm
    setuptools
  ];

  patches = [
    ./lxst-unvendor.diff
    ./lxst-deps.diff
  ];

  propagatedBuildInputs = [
    ffmpeg
  ];

  dependencies = [
    numpy
    pycodec2
    pydub
    pyogg
    myrns
    soundcard
  ];


  meta = with lib; {
    homepage = "https://github.com/markqvist/LXST";
    description = "lxst";
    mainProgram = "rnphone";
    maintainers = with maintainers; [ qbit ];
  };
}
