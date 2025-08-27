{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  codec2,
  cython,
  ffmpeg,
  libopus,
  numpy,
  pydub,
  lxmf,
  pytestCheckHook,
  rns,
  setuptools,
  setuptools-scm,
  soundcard,
  pkgs,
  ...
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
      (replaceVars ./pyogg-paths.patch {
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
  version = "unstable-2025-05-12";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "markqvist";
    repo = pname;
    rev = "a0098cf74fb68d615c14951ccebae75d7797e374";
    hash = "sha256-Lb13M1Au+DOK7Uxcieo+57r6pnNtJdtESPUXVAoODO8=";
  };

  #SETUPTOOLS_SCM_PRETEND_VERSION = version;

  doCheck = true;

  nativeBuildInputs = [
    setuptools-scm
    setuptools
  ];

  patches = [
    ./lxst-unvendor.diff

  ];

  propagatedBuildInputs = [
    ffmpeg
  ];

  dependencies = [
    numpy
    pycodec2
    pydub
    pyogg
    rns
    lxmf
    soundcard
  ];

  meta = with lib; {
    homepage = "https://github.com/markqvist/LXST";
    description = "lxst";
    mainProgram = "rnphone";
    maintainers = with maintainers; [ qbit ];
  };
}
