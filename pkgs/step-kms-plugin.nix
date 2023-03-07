{ lib, buildGoModule, fetchFromGitHub, pkg-config, pcsclite, softhsm
, writeScriptBin }:

let
  getScriptName = "get_softhsm_so_path";
  getSoftHSMsoPath = writeScriptBin getScriptName ''
    #!/usr/bin/env sh
    echo ${softhsm}/lib/softhsm/libsofthsm2.so
  '';

in buildGoModule rec {
  pname = "step-kms-plugin";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "smallstep";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-SvdV/eB+VWVMKPLptGWKPey4iUwkNXTyma+VBOzWwg8=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ pcsclite softhsm ];

  ldflags = [ "-w" "-s" "-X main.Version=${version}" ];

  vendorHash = "sha256-Z1hMZGRLiLlrYlyV4GBL+zCPJv+i/EcZPI07RinpY2Q=";

  postBuild = ''
    mkdir -p $out/bin
    ln -s ${getSoftHSMsoPath}/bin/get_softhsm_so_path $out/bin/
  '';

  meta = with lib; {
    description =
      "step plugin to manage keys and certificates on cloud KMSs and HSMs";
    longDescription = ''
      An extra script (${getScriptName}) is included to return the path to 'libsofthsm2.so'.
    '';
    homepage = "https://smallstep.com/cli/";
    license = licenses.asl20;
    maintainers = with maintainers; [ qbit ];
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "step-kms-plugin";
  };
}
