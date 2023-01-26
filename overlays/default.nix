{ self, config, pkgs, lib, isUnstable, ... }:
let
  tailscale = self: super: {
    tailscale = super.callPackage "${super.path}/pkgs/servers/tailscale" {
      buildGoModule = args:
        super.buildGo119Module (args // rec {
          version = "1.36.0";
          src = super.fetchFromGitHub {
            owner = "tailscale";
            repo = "tailscale";
            rev = "v${version}";
            sha256 = "sha256-hNyEABs/GdfOx6vLTVBgbOzkbFvEDYZ0y1y0a0mIsfA=";
          };
          vendorSha256 = "sha256-Jy3kjUA8qLhcw9XLw4Xo1zhD+IWZrDNM79TsbnKpx/g=";
          ldflags = [
            "-X tailscale.com/version.Long=${version}"
            "-X tailscale.com/version.Short=${version}"
          ];
        });
    };
  };
in {
  nixpkgs.overlays = if isUnstable then [
    tailscale
    (self: super: {
      rex = super.rex.overrideAttrs (old: {
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
    (self: super: {
      aerc = super.aerc.overrideAttrs (old: {
        patches = [
          (pkgs.fetchurl {
            url =
              "https://lists.sr.ht/~rjarry/aerc-devel/%3C20221218160541.680374-1-moritz%40poldrack.dev%3E/raw";
            sha256 = "sha256-qPRMOuPs5Pxiu2p08vGxsoO057Y1rVltPyBMbJXsH1s=";
          })
        ];
      });
    })
  ] else
    [ tailscale ];
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
