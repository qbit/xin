{
  buildPythonPackage,
  lib,
  fetchurl,
  python,
  weechat,
  ...
}:
buildPythonPackage {
  pname = "weepushover";
  version = "0.1";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/weechat/scripts/77a0c0bf2b0da64c33a50d8f8514d0467b0569e4/python/weepushover.py";
    hash = "sha256-msOdNfYg88Wq00UJIRNu1OjKSUO0Kfq5rvLbIET2eo4=";
  };

  propagatedBuildInputs = [ ];

  dontUnpack = true;

  passthru.scripts = [ "weepushover.py" ];

  dontBuild = true;
  doCheck = false;

  format = "other";

  installPhase = ''
    runHook preInstall
    install -D $src $out/share/weepushover.py
    runHook postInstall
  '';

  dontPatchShebangs = true;
  postFixup = ''
    addToSearchPath program_PYTHONPATH $out/${python.sitePackages}
    patchPythonScript $out/share/weepushover.py
  '';

  meta = with lib; {
    inherit (weechat.meta) platforms;
    homepage = "https://github.com/adtac/weepushover";
    description = "push notifications from weechat to pushover";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
