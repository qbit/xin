{ isUnstable, lib, xinlib, ... }:
let
  openssh = import ./openssh.nix;
  tailscale = xinlib.prIsOpen 231281 (import ./tailscale.nix);
  jetbrains = xinlib.prIsOpen 232308 (import ./jetbrains.nix);
  tidal-hifi = xinlib.prIsOpen 228552 (import ./tidal-hifi.nix { inherit lib; });
in {
  nixpkgs.overlays = if isUnstable then [
    (_: super: {
      elmPackages = super.elmPackages // {
        elm = super.elmPackages.elm.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ [ ./elm-no-color.diff ];
        });
      };
    })
    jetbrains
    tidal-hifi
    openssh
    tailscale
  ] else [
    (import ./matrix-synapse.nix)
    openssh
    tailscale
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
