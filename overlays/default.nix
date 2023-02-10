{ self, config, pkgs, lib, isUnstable, ... }:
let
  openssh = import ./openssh.nix;
  tailscale = import ./tailscale.nix;
  matrix-synapse = import ./matrix-synapse.nix;

in {
  nixpkgs.overlays = if isUnstable then [
    openssh
    tailscale

    # https://github.com/NixOS/nixpkgs/pull/213613
    (self: super: {
      tidal-hifi = super.tidal-hifi.overrideAttrs (old: rec {
        version = "4.4.0";

        src = super.fetchurl {
          url =
            "https://github.com/Mastermindzh/tidal-hifi/releases/download/${version}/tidal-hifi_${version}_amd64.deb";
          sha256 = "sha256-6KlcxBV/zHN+ZnvIu1PcKNeS0u7LqhDqAjbXawT5Vv8=";
        };

        postFixup = ''
          makeWrapper $out/opt/tidal-hifi/tidal-hifi $out/bin/tidal-hifi \
            --prefix LD_LIBRARY_PATH : "${
              lib.makeLibraryPath old.buildInputs
            }" \
            "''${gappsWrapperArgs[@]}"
          substituteInPlace $out/share/applications/tidal-hifi.desktop \
            --replace "/opt/tidal-hifi/tidal-hifi" "tidal-hifi"

          for size in 48 64 128 256 512; do
            mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps/
            convert $out/share/icons/hicolor/0x0/apps/tidal-hifi.png \
              -resize ''${size}x''${size} $out/share/icons/hicolor/''${size}x''${size}/apps/icon.png
          done
        '';

      });
    })
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
