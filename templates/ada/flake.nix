{
  description = "thing: stuff and things";

  inputs.nixpkgs.url = "nixpkgs/nixos-22.11";

  outputs = { self, nixpkgs }:
    let
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          thing = pkgs.stdenv.mkDerivation {
            pname = "thing";
            version = "v0.0.0";
            src = ./.;
            buildInputs = with pkgs; [ gnat12 gprbuild ];

            buildPhase = ''
              gprbuild thing
            '';

            installPhase = ''
              mkdir -p $out/bin
              mv thing $out/bin
            '';
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
              echo "Ada `${pkgs.gnat12}/bin/gnatmake --version`"
            '';
            nativeBuildInputs = with pkgs; [ gnat12 gprbuild ];
          };
        });
    };
}

