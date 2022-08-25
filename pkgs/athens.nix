{ stdenv, lib, buildGoModule, fetchFromGitHub, isUnstable, makeWrapper, go, git
, ... }:

let
  vendorHash = if isUnstable then
    ""
  else
    "sha256-7CnkKMZ1so1lflmp4D9EAESR6/u9ys5CTuVOsYetp0I=";

in with lib;
buildGoModule rec {
  pname = "athens";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "gomods";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-hkewZ21ElkoDsbPPiCZNmWu4MBlKTlnrK72/xCX06Sk=";
  };

  doCheck = false;

  ldflags = [ "-X github.com/gomods/athens/pkg/build.version=${version}" ];

  nativeBuildInputs = lib.optionals stdenv.isLinux [ makeWrapper go ];

  proxyVendor = true;

  subPackages = [ "cmd/proxy" ];

  vendorSha256 = vendorHash;

  postInstall = lib.optionalString stdenv.isLinux ''
    mv $out/bin/proxy $out/bin/athens
    wrapProgram $out/bin/athens --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  meta = {
    description = "A Go module datastore and proxy";
    homepage = "https://github.com/gomods/athens";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
