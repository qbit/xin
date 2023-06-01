{
  description = "thing: stuff and things";

  inputs.nixpkgs.url = "nixpkgs/nixos-23.05";

  outputs = { self, nixpkgs }:
    let
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in {
      overlay = _: prev: { inherit (self.packages.${prev.system}) thing; };

      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          thing = pkgs.buildGoModule {
            pname = "thing";
            version = "v0.0.0";
            src = ./.;

            vendorHash = pkgs.lib.fakeSha256;
            proxyVendor = true;

            nativeBuildInputs = with pkgs; [ pkg-config ];
            buildInputs = with pkgs; [
              git
              glfw
              libGL
              libGLU
              openssh
              pkg-config
              xorg.libXcursor
              xorg.libXi
              xorg.libXinerama
              xorg.libXrandr
              xorg.libXxf86vm
              xorg.xinput
            ];
          };
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.thing);
      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default = pkgs.mkShell {
            shellHook = ''
              PS1='\u@\h:\@; '
              nix flake run github:qbit/xin#flake-warn
              echo "Go `${pkgs.go}/bin/go version`"
            '';
            buildInputs = with pkgs; [
              git
              go_1_20
              gopls
              go-tools

              glfw
              pkg-config
              xorg.libXcursor
              xorg.libXi
              xorg.libXinerama
              xorg.libXrandr
              xorg.libXxf86vm
              xorg.xinput
            ];
          };
        });
    };
}

