{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}:
with lib;
  buildGoModule rec {
    name = "vuln";

    src = fetchFromGitHub {
      owner = "golang";
      repo = name;
      rev = "03dd099d9b0dd4e0a3ab25b3192b9d95c97252ea";
      sha256 = "sha256-UJ2svg/exjwH/T3dqHixRgD6ZqYjbV/MpnEEaFza6Ns=";
    };

    vendorSha256 = "sha256-tk186BCy8l0o1mxaWXcz0BWVMvvMvhEGcTmDdthJlcc=";

    #>   github.com/tidwall/pretty@v1.2.0: is explicitly required in go.mod, but not marked as explicit in vendor/modules.txt
    doCheck = false;

    subPackages = ["cmd/govulncheck"];

    meta = {
      description = "tools for the Go vulnerability database";
      homepage = "https://github.com/golang/vuln";
      license = licenses.isc;
      maintainers = with maintainers; [qbit];
    };
  }
