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
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          thing = pkgs.stdenv.mkDerivation {
            pname = "thing";
            version = "v0.0.0";
            src = ./.;
            buildInputs = with pkgs;
              [ ocaml opam ocamlformat pkg-config ]
              ++ (with pkgs.ocamlPackages; [ dune_3 odoc ]);

            buildPhase = ''
              ocamlc -o thing thing.ml
            '';

            installPhase = ''
              mkdir -p $out/bin
              mv thing $out/bin
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
              echo "OCaml `${pkgs.ocaml}/bin/ocaml --version`"
            '';
            nativeBuildInputs = with pkgs;
              [ ocaml opam ocamlformat pkg-config ]
              ++ (with pkgs.ocamlPackages; [ dune_3 odoc ]);
          };
        });
    };
}
