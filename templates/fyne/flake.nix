{
  description = "thing: stuff and things";

  inputs.nixpkgs.url = "nixpkgs/nixos-24.11";

  outputs =
    { self
    , nixpkgs
    ,
    }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      overlay = _: prev: { inherit (self.packages.${prev.system}) thing; };

      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          thing = pkgs.buildGoModule rec {
            pname = "thing";
            version = "v0.0.0";
            src = ./.;

            vendorHash = pkgs.lib.fakeSha256;
            proxyVendor = true;

            nativeBuildInputs = with pkgs; [ pkg-config ];
            buildInputs = with pkgs; [
              fyne
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

            buildPhase = ''
              ${fyne}/bin/fyne package
            '';

            installPhase = ''
              mkdir -p $out
              pkg="$PWD/${pname}.tar.xz"
              cd $out
              tar --strip-components=1 -xvf $pkg
            '';
          };
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.thing);
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            shellHook = ''
              PS1='\u@\h:\@; '
              nix run github:qbit/xin#flake-warn
              echo "Go `${pkgs.go}/bin/go version`"
            '';
            buildInputs = with pkgs; [
              fyne
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
