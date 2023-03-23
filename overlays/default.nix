{ pkgs, isUnstable, ... }:
let
  openssh = import ./openssh.nix;
  tailscale = import ./tailscale.nix;
  jetbrains = import ./jetbrains.nix;
  matrix-synapse = import ./matrix-synapse.nix;

in {
  nixpkgs.overlays = if isUnstable then [
    jetbrains
    openssh
    tailscale

    (_: super: {
      rex = super.rex.overrideAttrs (_: {
        patches = [
          (pkgs.fetchurl {
            url = "https://deftly.net/rex-git.diff";
            sha256 = "sha256-hLzWJydIBxAVXLTcqYFTLuWnMgPwNE6aZ+4fDN4agrM=";
          })
        ];
        nativeBuildInputs = with pkgs.perlPackages; [
          ParallelForkManager
          pkgs.installShellFiles
        ];

        outputs = [ "out" ];

        fixupPhase = ''
          substituteInPlace ./share/rex-tab-completion.zsh \
            --replace 'perl' "${
              pkgs.perl.withPackages (ps: [ ps.YAML ])
            }/bin/perl"
          substituteInPlace ./share/rex-tab-completion.bash \
            --replace 'perl' "${
              pkgs.perl.withPackages (ps: [ ps.YAML ])
            }/bin/perl"
          installShellCompletion --name _rex --zsh ./share/rex-tab-completion.zsh
          installShellCompletion --name _rex --bash ./share/rex-tab-completion.bash
        '';

      });
    })
  ] else [
    matrix-synapse
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
