{
  description = "thing: stuff and things";

  inputs.nixpkgs.url = "nixpkgs/nixos-25.05";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          thing = pkgs.stdenv.mkDerivation {
            pname = "thing";
            version = "v0.0.0";
            src = ./.;
            buildInputs = with pkgs.perlPackages; [
              PerlTidy
              perl
            ];
            nativeBuildInputs = with pkgs.perlPackages; [
              perl
              Mojolicious
              MojoSQLite
            ];

            installPhase = ''
              mkdir -p $out/bin
              install -t $out/bin thing.pl
            '';
          };
        }
      );

      defaultPackage = forAllSystems (system: self.packages.${system}.thing);
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            shellHook = ''
              PS1='\u@\h:\@; '
              nix run github:qbit/xin#flake-warn
              echo "Perl `${pkgs.perl}/bin/perl --version`"
            '';
            buildInputs = with pkgs.perlPackages; [ PerlTidy ];
            nativeBuildInputs = with pkgs.perlPackages; [
              perl
              Mojolicious
              MojoSQLite
            ];
          };
        }
      );
    };
}
