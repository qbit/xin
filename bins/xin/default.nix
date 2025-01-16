{ pkgs, ... }:
with pkgs;
perlPackages.buildPerlPackage {
  pname = "xin";
  version = "v0.0.1";
  src = ./.;
  buildInputs = with pkgs; [ perlPackages.JSON ];

  outputs = [ "out" "dev" ];

  installPhase = ''
    mkdir -p $out/bin
    install xin.pl $out/bin/xin
  '';
}

