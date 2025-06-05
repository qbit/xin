{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  dbus,
  simpleDBus,
  openssl,
  libudev-zero,
}:
rustPlatform.buildRustPackage rec {
  pname = "intiface-engine";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "intiface";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-8voURSl4l5AJrXNCLl9BXbUJNLvNphk7kosJVdgqhRI=";
  };

  VERGEN_GIT_SHA_SHORT = "98df405";
  VERGEN_BUILD_TIMESTAMP = "2024-09-08";

  cargoHash = "sha256-Y0J2ZKa7MPaTbLrlsD6mdu6mrBIGKG6cXBj/a0Qeb3Q=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
    simpleDBus
    openssl
    libudev-zero
  ];

  meta = with lib; {
    description = "CLI and Library frontend for Buttplug";
    homepage = "https://github.com/intiface/intiface-engine";
    license = licenses.bsd3;
    maintainers = [ maintainers.qbit ];
  };
}
