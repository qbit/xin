{ self, config, pkgs, lib, isUnstable, ... }:

{
  nixpkgs.overlays = if isUnstable then [
    (self: super: {
      zig = super.zig.overrideAttrs (old: {
        version = "0.10.0-dev.35e0ff7";
        src = super.fetchFromGitHub {
          owner = "ziglang";
          repo = "zig";
          rev = "35e0ff7c364487152d786347cf70f47b2a390f12";
          hash = "sha256-S6m0TrE+Ecm9yBJHgTZRMcKr0W0SoSZYX2CB+5gUSAY=";
        };

        patches = [ ];

        nativeBuildInputs = with pkgs; [ cmake llvmPackages_14.llvm.dev ];

        buildInputs = with pkgs;
          [ libxml2 zlib ] ++ (with llvmPackages_14; [ libclang lld llvm ]);

        checkPhase = ''
          runHook preCheck
          ./zig2 test --cache-dir "$TMPDIR" -I $src/test $src/test/behavior.zig
          runHook postCheck
        '';
      });
    })

    # https://github.com/NixOS/nixpkgs/pull/186130
    (self: super: {
      tidal-hifi = super.tidal-hifi.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.imagemagick ];
        postFixup = ''
          makeWrapper $out/opt/tidal-hifi/tidal-hifi $out/bin/tidal-hifi \
            --prefix LD_LIBRARY_PATH : "${
              lib.makeLibraryPath super.tidal-hifi.buildInputs
            }" \
            "''${gappsWrapperArgs[@]}"

          substituteInPlace $out/share/applications/tidal-hifi.desktop --replace \
            "/opt/tidal-hifi/tidal-hifi" "tidal-hifi"

          for size in 48 64 128 256 512; do
            mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps/
            convert $out/share/icons/hicolor/0x0/apps/tidal-hifi.png \
              -resize ''${size}x''${size} \
              $out/share/icons/hicolor/''${size}x''${size}/apps/tidal-hifi.png
          done
        '';

      });
    })

    (self: super: {
      wireplumber = super.wireplumber.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (super.fetchpatch {
            url =
              "https://gitlab.freedesktop.org/pipewire/wireplumber/-/merge_requests/398.patch";
            sha256 = "sha256-rEp/3fjBRbkFuw4rBW6h8O5hcy/oBP3DW7bPu5rVfNY=";
          })
        ];
      });
    })
  ] else
    [ ];
}
