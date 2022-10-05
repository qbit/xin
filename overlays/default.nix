{ self, config, pkgs, lib, isUnstable, ... }:

{
  nixpkgs.overlays = if isUnstable then [

    (self: super: {
      openssh = super.openssh.overrideAttrs (old: {
        version = "9.1p1";

        src = super.fetchurl {
          url = "mirror://openbsd/OpenSSH/portable/openssh-9.1p1.tar.gz";
          hash = "sha256-GfhQCcfj4jeH8CNvuxV4OSq01L+fjsX+a8HNfov90og=";
        };
      });
    })

    # https://github.com/NixOS/nixpkgs/pull/194589
    (self: super: {
      tidal-hifi = super.tidal-hifi.overrideAttrs (old: {
        postFixup = ''
          makeWrapper $out/opt/tidal-hifi/tidal-hifi $out/bin/tidal-hifi \
            --prefix LD_LIBRARY_PATH : "${
              lib.makeLibraryPath super.tidal-hifi.buildInputs
            }" \
            "''${gappsWrapperArgs[@]}"
          substituteInPlace $out/share/applications/tidal-hifi.desktop \
            --replace "/opt/tidal-hifi/tidal-hifi" "tidal-hifi" \
            --replace "/usr/share/icons/hicolor/0x0/apps/tidal-hifi.png" "tidal-hifi.png"
          for size in 48 64 128 256 512; do
            mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps/
            convert $out/share/icons/hicolor/0x0/apps/tidal-hifi.png \
              -resize ''${size}x''${size} $out/share/icons/hicolor/''${size}x''${size}/apps/tidal-hifi.png
          done
        '';
      });
    })

    (self: super: {
      zig = super.zig.overrideAttrs (old: {
        version = "0.10.0-dev.35e0ff7";
        src = super.fetchFromGitHub {
          owner = "ziglang";
          repo = "zig";
          rev = "10e11b60e56941cb664648dcebfd4db3d2efed30";
          hash = "sha256-oD5yfvaaVtgW/VE+5yHCiJgC+QMwiLe2i+PGX3g/PT0=";
        };

        patches = [ ];

        nativeBuildInputs = with pkgs; [ cmake llvmPackages_14.llvm.dev ];

        buildInputs = with pkgs;
          [ libxml2 zlib ] ++ (with llvmPackages_14; [ libclang lld llvm ]);

        checkPhase = ''
          runHook preCheck
          runHook postCheck
        '';

      });
    })
  ] else
    [ ];
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

