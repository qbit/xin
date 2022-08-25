{ lib, buildGoModule, fetchFromGitHub, isUnstable, ... }:

let
  vendorHash = if isUnstable then
    "sha256-lUVngyYnLwCmNXFBMEDO7ecFZNkSi9GGDNTIG4Mk1Zw="
  else
    "sha256-oBZaMS7O6MvvznVn9kQ7h0srWvD3VvxerXgghj0CIzM=";

in with lib;
buildGoModule rec {
  pname = "gitmux";
  version = "0.7.9";

  src = fetchFromGitHub {
    owner = "arl";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-tB/HPOJQEgs3/rHFn7ezi6R9C3HceASLU3WjjKDii9o=";
  };

  vendorSha256 = vendorHash;

  ldflags = [ "-X main.version=${version}" ];

  proxyVendor = true;

  doCheck = false;

  meta = {
    description = "Gitmux shows git status in your tmux status bar";
    homepage = "https://github.com/arl/gitmux";
    license = licenses.mit;
    maintainers = with maintainers; [ qbit ];
  };
}
