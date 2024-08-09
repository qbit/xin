{ lib, rustPlatform, fetchFromGitHub, pkg-config, dbus, simpleDBus, openssl, libudev-zero }:
rustPlatform.buildRustPackage rec {
  pname = "intiface-engine";
  version = "1.4.8";

  src = fetchFromGitHub {
    owner = "intiface";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-qhCvD1po1fXaGLxGv5/amCYKUakOf1VGu7KHfKPyDGI=";
  };

  VERGEN_GIT_SHA_SHORT = "98df405";
  VERGEN_BUILD_TIMESTAMP = "2024-09-08";

  cargoHash = "sha256-JbZsNTysnryQO/+hzCLBFXh79O/kQeW+GRldMF5blxw=";

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
