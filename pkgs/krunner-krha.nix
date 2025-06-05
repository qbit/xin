{
  stdenv,
  fetchFromGitHub,
  python3,
  wrapGAppsHook,
  gobject-introspection,
}:
let
  pythonEnv = python3.withPackages (
    p: with p; [
      dbus-python
      pygobject3
      requests
    ]
  );
in
stdenv.mkDerivation {
  pname = "krunner-krha";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "qbit";
    repo = "krha";
    rev = "8eec95fd64e44155aac6818d6a17d288da1ae030";
    hash = "sha256-/QQZLQMsff6KwBv3UQiHaOQJw4DJdbrehj4YQ+5Mis4=";
  };

  nativeBuildInputs = [
    pythonEnv
    wrapGAppsHook
    gobject-introspection
  ];

  installPhase = ''
    runHook preInstall

    patchShebangs krha.py


    echo "[D-BUS Service]" > krha.service
    echo "Name=dev.suah.krha" >> krha.service
    echo "EnvironmentFile=/run/secrets/krha_env_file" >> krha.service
    echo "Exec=$out/libexec/krha.py" >> krha.service

    install -D krha.service $out/share/dbus-1/services/dev.suah.krha.service
    install -m 0755 -D krha.py $out/libexec/krha.py
    install -D plasma-runner-krha.desktop $out/share/krunner/dbusplugins/plasma-runner-krha.desktop

    runHook postInstall
  '';
}
