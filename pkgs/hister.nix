{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fetchNpmDeps,
  nodejs,
  sqlite,
  ...
}:
with lib;
let
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "asciimoo";
    repo = "hister";
    rev = "v${version}";
    sha256 = "sha256-99lFNE745cfHHh/wETbnf9LSUbDeF6hQWCtC2u43pds=";
  };

  npmDeps = fetchNpmDeps {
    src = "${src}/server/static/js";
    hash = "sha256-BupgGlAhzanFyjv43terHsUUjmAxFniwMSBLFi8shC0=";
  };
in
buildGoModule (finalAttrs: {
  pname = "hister";
  inherit version src;

  vendorHash = "sha256-KEuZ+jKG3fMYymZr9fvwlTzLFVcYfUAofe8DOIqHUDY=";
  proxyVendor = true;

  nativeBuildInputs = [
    nodejs
  ];

  buildInputs = [ sqlite ];

  preBuild = ''
    cd server/static/js

    mkdir -p $TMPDIR/npm-cache
    cp -r ${npmDeps}/* $TMPDIR/npm-cache/
    export NPM_CONFIG_CACHE=$TMPDIR/npm-cache

    npm ci --offline
    node node_modules/.bin/vite build

    cd ../..

    export CGO_CFLAGS="-I${sqlite.dev}/include"
    export CGO_LDFLAGS="-L${sqlite.out}/lib -lsqlite3"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=${histerRev}"
  ];

  subPackages = [ "." ];

  passthru = {
    inherit npmDeps;
  };

  meta = {
    description = "local search engine";
    homepage = "https://github.com/asciimoo/hister";
    license = licensesSpdx."Apache-2.0";
    mainProgram = "hister";
    maintainers = with maintainers; [ qbit ];
  };
})
