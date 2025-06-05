let
  perlPackages = _: super: {
    PLS =
      let
        FutureQueue = super.buildPerlModule {
          pname = "Future-Queue";
          version = "0.51";
          src = super.fetchurl {
            url = "mirror://cpan/authors/id/P/PE/PEVANS/Future-Queue-0.51.tar.gz";
            hash = "sha256-HVAcOpot3/x8YPlvpmlp1AyykuCSBM9t7NHCuLUAPNY=";
          };
          buildInputs = with super.perlPackages; [ Test2Suite ];
          propagatedBuildInputs = with super.perlPackages; [ Future ];
          meta = {
            description = "A FIFO queue of values that uses L<Future>s";
            license = with super.lib.licenses; [
              artistic1
              gpl1Plus
            ];
          };
        };
      in
      super.PLS.overrideAttrs (_: {
        propagatedBuildInputs = with super.perlPackages; [
          Future
          FutureQueue
          IOAsync
          PPI
          PPR
          PathTiny
          PerlCritic
          PerlTidy
          PodMarkdown
          URI
        ];
      });
  };
in
perlPackages
