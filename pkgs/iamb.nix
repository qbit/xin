{ lib, rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage rec {
  pname = "iamb";
  version = "2023-03-09";

  src = fetchFromGitHub {
    owner = "ulyssa";
    repo = pname;
    rev = "066f60ad321eb7d16a9535744ec0193b36468c37";
    hash = "sha256-IX28ZquUqt7GOTPWX9XgEZGbx7vWLrRS6jn5Y9smE1k=";
  };

  cargoHash = "sha256-5ujLOmtb9fZ4YhfA/OKHFxLWfcKBERndFMj7BbdTJZ4=";

  meta = with lib; {
    description = "A Matrix client for Vim addicts";
    homepage = "https://github.com/ulyssa/iamb";
    license = licenses.asl20;
    maintainers = [ maintainers.qbit ];
  };
}

