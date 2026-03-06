{
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  importNpmLock,
  pkg-config,
  sqlite,
  lib,
  ...
}:
with lib;
let
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "asciimoo";
    repo = "hister";
    rev = "v${version}";
    sha256 = "sha256-beVyZLrpewxG3gWCQMRLI3UC4cZhob8GTW9XbfyWbU8=";
  };

  frontend = buildNpmPackage {
    pname = "hister-frontend";
    inherit version src;

    npmConfigHook = importNpmLock.npmConfigHook;
    npmWorkspace = "webui/app";
    npmDeps = importNpmLock { npmRoot = src; };

    dontNpmBuild = false;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r webui/app/build/* $out/
      runHook postInstall
    '';
  };
in
buildGoModule (finalAttrs: {
  pname = "hister";
  inherit version src;

  vendorHash = "sha256-u7ebtGWjtf0ELKe2xeoqxt633hg85JUPvvq134bhnmM=";
  proxyVendor = true;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ sqlite ];

  tags = [ "libsqlite3" ];

  preBuild = ''
    mkdir -p server/static/app
    cp -r ${frontend}/* server/static/app/
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  passthru = {
    inherit frontend;
  };

  meta = {
    description = "local search engine";
    homepage = "https://github.com/asciimoo/hister";
    license = licensesSpdx."Apache-2.0";
    mainProgram = "hister";
    maintainers = with maintainers; [ qbit ];
  };
})
