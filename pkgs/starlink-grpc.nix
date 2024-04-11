{ buildPythonPackage
, fetchFromGitHub
, grpc
, pytest
, pytest-grpc
, grpcio
, grpcio-reflection
, protobuf
, setuptools-scm
, typing-extensions
, ...
}:
let
  yagrc = buildPythonPackage rec {
    pname = "yagrc";
    version = "1.1.2";

    pyproject = true;

    nativeBuildInputs = [
      setuptools-scm
    ];

    propagatedBuildInputs = [
      grpc
      grpcio
      grpcio-reflection
      protobuf
    ];

    nativeCheckInputs = [
      pytest
      pytest-grpc
    ];

    checkPhase = ''
      pytest
    '';

    src = fetchFromGitHub {
      owner = "sparky8512";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-nqUzDJfLsI8n8UjfCuOXRG6T8ibdN6fSGPPxm5RJhQk=";
    };
  };
in
buildPythonPackage rec {
  pname = "starlink-grpc";
  version = "1.1.3";

  pyproject = true;

  nativeBuildInputs = [
    setuptools-scm
  ];

  propagatedBuildInputs = [
    grpc
    grpcio
    protobuf
    typing-extensions
    yagrc
  ];

  postPatch = ''
    cd packaging
  '';

  src = fetchFromGitHub {
    owner = "sparky8512";
    repo = "starlink-grpc-tools";
    rev = "v${version}";
    hash = "sha256-sb9UH+PuMYY6USNMoB2+mjjufcGf2LzUdAOLQGmpNow=";
  };
}
