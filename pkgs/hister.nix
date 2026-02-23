{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:
with lib;
buildGoModule rec {
  pname = "hister";
  version = "v0.4.0";

  src = fetchFromGitHub {
    owner = "asciimoo";
    repo = pname;
    rev = version;
    sha256 = "sha256-tPpLUE1xJ3PskxAUfrjUDAK0kiJzelWqNU/WKZPNY8Y=";
  };

  vendorHash = "sha256-Tnvr9TqP7BNGmZ+0wrEfi9FH6KteLVORH3qUFWjn02Q=";

  meta = {
    description = "local search engine";
    homepage = "https://github.com/asciimoo/hister";
    license = licensesSpdx."Apache-2.0";
    maintainers = with maintainers; [ qbit ];
  };
}
