{ lib
, buildGoModule
, fetchFromGitHub
, ...
}:
with lib;
buildGoModule rec {
  pname = "rtlamr";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "bemasher";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-0LufLU/wTmCRqTnQBNJg5UnDv0u1Thec5FSWATWqZsQ=";
  };

  vendorHash = "sha256-uT6zfsWgIot0EMNqwtwJNFXN/WaAyOGfcYJjuyOXT4g=";

  meta = {
    description = "rtl-sdr receiver for Itron ETR meters";
    homepage = "https://github.com/bemasher/rtlamr";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ qbit ];
  };
}
