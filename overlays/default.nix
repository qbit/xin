{ isUnstable, xinlib, ... }:
let
  inherit (xinlib) prIsOpen;
  _1password-gui = prIsOpen.overlay 235900 (import ./1password-gui.nix);
  #openssh = import ./openssh.nix;
  #obsidian = prIsOpen.overlay 235408 (import ./obsidian.nix);
  #tailscale = import ./tailscale.nix;
  #jetbrains = prIsOpen 232308 (import ./jetbrains.nix);
  #tidal-hifi = prIsOpen 228552 (import ./tidal-hifi.nix { inherit lib; });
  matrix-synapse = prIsOpen.overlay 0 (import ./matrix-synapse.nix);
in {
  nixpkgs.overlays =
    if isUnstable then [ _1password-gui ] else [ matrix-synapse ];
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
