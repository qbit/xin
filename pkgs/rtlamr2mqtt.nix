{
  buildPythonPackage,
  callPackage,
  fetchFromGitHub,
  paho-mqtt,
  pyusb,
  pyyaml,
  requests,
  rtl-sdr,
  ...
}: let
  rtlamr = callPackage ./rtlamr.nix {};
in
  buildPythonPackage {
    pname = "rtlamr2mqtt";
    version = "unstable-2023-08-17";

    format = "none";

    nativeBuildInputs = [];
    propagatedBuildInputs = [paho-mqtt pyyaml requests pyusb rtlamr rtl-sdr];

    doCheck = false;
    doBuild = false;

    installPhase = ''
      mkdir -p $out/bin
      cp rtlamr2mqtt-addon/rtlamr2mqtt.py $out/bin/rtlamr2mqtt
      cp rtlamr2mqtt-addon/sdl_ids.txt $out/
    '';

    src = fetchFromGitHub {
      owner = "qbit";
      repo = "rtlamr2mqtt";
      hash = "sha256-WqW+RZQhwYAIvBAizO3/7SdlhWR9ZIIliEq76XwsUEo=";
      rev = "631504e";
    };

    meta = {
      mainProgram = "rtlamr2mqtt";
    };
  }
