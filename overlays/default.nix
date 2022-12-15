{ self, config, pkgs, lib, isUnstable, ... }:

{
  nixpkgs.overlays = if isUnstable then
    [ ]
  else
    [
      (self: super: {
        matrix-synapse = super.matrix-synapse.overrideAttrs (old: rec {
          version = "1.73.0";
          src = super.fetchFromGitHub {
            owner = "matrix-org";
            repo = "synapse";
            rev = "v${version}";
            sha256 = "sha256-Er5a+0Qyvm5V1ObWjDQ8fs+r/XB+4aRItJMqaz1VSqk=";
          };

          cargoDeps = super.rustPlatform.fetchCargoTarball {
            inherit src;
            name = "matrix-synapse-${version}";
            sha256 = "sha256-yU72e8OBnUtNdUI/crX7v2KRYHHHOY4Ga9CI3PJwais=";
          };
        });
      })

    ];
}

# Example Python dep overlay
# (self: super: {
#   python3 = super.python3.override {
#     packageOverrides = python-self: python-super: {
#       canonicaljson = python-super.canonicaljson.overrideAttrs (oldAttrs: {
#         nativeBuildInputs = [ python-super.setuptools ];
#       });
#     };
#   };
# })

# Example of an overlay that changes the buildGoModule function
#tailscale = self: super: {
#  tailscale = super.callPackage "${super.path}/pkgs/servers/tailscale" {
#    buildGoModule = args:
#      super.buildGo119Module (args // rec {
#        version = "1.32.2";
#        src = super.fetchFromGitHub {
#          owner = "tailscale";
#          repo = "tailscale";
#          rev = "v${version}";
#          sha256 = "sha256-CYNHD6TS9KTRftzSn9vAH4QlinqNgU/yZuUYxSvsl/M=";
#        };
#        vendorSha256 = "sha256-VW6FvbgLcokVGunTCHUXKuH5+O6T55hGIP2g5kFfBsE=";
#      });
#  };
#};
