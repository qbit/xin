{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl_1_1,
  llvmPackages,
  libevdev,
  linuxHeaders,
  ...
}:
rustPlatform.buildRustPackage {
  pname = "rkvm";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "htrefil";
    repo = "rkvm";
    rev = "bf133665eb446d9f128d02e4440cc67bce50f666";
    sha256 = "sha256-naWoLo3pPETkYuW4HATkrfjGcEHSGAAXixgp1HOlIcg=";
  };

  cargoSha256 = "sha256-5COhHc453QYiUoCtucg/Sz9bGq/Bpn/muDDZTsEsRII=";

  BINDGEN_EXTRA_CLANG_ARGS = "-I${lib.getDev libevdev}/include/libevdev-1.0";
  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  nativeBuildInputs = [
    llvmPackages.clang
    pkg-config
    openssl_1_1
  ];
  buildInputs = [
    libevdev
    openssl_1_1
    linuxHeaders
  ];

  doCheck = false;

  postInstall = ''
    mv $out/bin/certificate-gen $out/bin/rkvm-cert-gen
    mv $out/bin/server $out/bin/rkvm-server
    mv $out/bin/client $out/bin/rkvm-client
  '';

  meta = with lib; {
    description = "Virtual KVM switch for Linux machines";
    homepage = "https://github.com/htrefil/rkvm";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "rkvm";
  };
}
