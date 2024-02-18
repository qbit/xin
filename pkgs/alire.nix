{
  stdenv,
  lib,
  fetchurl,
  unzip,
  autoPatchelfHook,
  ...
}:
with lib;
stdenv.mkDerivation rec {
  pname = "alire";
  version = "1.2.1";

  src = fetchurl {
    url = "https://github.com/alire-project/alire/releases/download/v1.2.1/alr-1.2.1-bin-x86_64-linux.zip";
    sha256 = "sha256-bN/H5CPN7uvUH9+p+y/sg01qTJI3asToxVSVnKVNHuM=";
  };

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
  ];

  dontBuild = true;
  doCheck = false;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -D alr $out/bin/
    runHook postInstall
  '';

  meta = {
    description = "ALIRE: Ada LIbrary REpository.";
    homepage = "https://github.com/alire-project/alire";
    license = licenses.gpl3;
    maintainers = with maintainers; [ qbit ];
  };
}
