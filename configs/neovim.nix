{ pkgs, ... }:
with pkgs;
let
  vimBuildTool = pkgs.vimUtils.buildVimPlugin;
  parchment = vimBuildTool rec {
    pname = "parchment";
    version = "0.4.0";
    src = pkgs.fetchFromGitHub {
      owner = "ajgrf";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-ZphConCGZR3EG6dd8Ji7U9Qtm21SoWMk60XD4X+My1g=";
    };
  };
  vacme = vimBuildTool rec {
    pname = "vacme";
    version = "2017-01-14";
    src = pkgs.fetchFromGitHub {
      owner = "olivertaylor";
      repo = pname;
      rev = "2f0b284b5bc1c9dd5b7f0b89ac880959e61b0be4";
      sha256 = "sha256-eea0Ntr3gCmF6iZ0adZaVswWH70K9IJZ4SAyVSdFp3E=";
    };
  };
  obsidian = vimBuildTool rec {
    pname = "obsidian-nvim";
    version = "2.3.1";
    src = pkgs.fetchFromGitHub {
      owner = "epwalsh";
      repo = "obsidian.nvim";
      rev = "v${version}";
      sha256 = "sha256-g9GFq5FMaCcJ6HbnhRgCmioLvaJ4SK6jSioDi5lXeP4=";
      fetchSubmodules = true;
    };
    dependencies = with vimPlugins; [ nvim-cmp tabular plenary-nvim ];
  };
  neogen = vimBuildTool rec {
    pname = "neogen";
    version = "2023-01-16";
    src = pkgs.fetchFromGitHub {
      owner = "danymat";
      repo = pname;
      rev = "465af9d6c6fb7f360175991dcc23fc10917e3a06";
      sha256 = "sha256-I8vlVDSJQqFfLkqRS8lwdVAEUxKwi+IKSGFVqZ6l2SE=";
      fetchSubmodules = true;
    };
  };

  MsgPackRaw = perlPackages.buildPerlPackage {
    pname = "MsgPack-Raw";
    version = "0.05";
    src = fetchurl {
      url = "mirror://cpan/authors/id/J/JA/JACQUESG/MsgPack-Raw-0.05.tar.gz";
      sha256 = "8559e2b64cd98d99abc666edf2a4c8724c9534612616af11f4eb0bbd0d422dac";
    };
    buildInputs = with perlPackages; [ TestPod TestPodCoverage ];
    meta = {
      description = "Perl bindings to the msgpack C library";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  EvalSafe = perlPackages.buildPerlPackage {
    pname = "Eval-Safe";
    version = "0.02";
    src = fetchurl {
      url = "mirror://cpan/authors/id/M/MA/MATHIAS/Eval-Safe/Eval-Safe-0.02.tar.gz";
      sha256 = "55a52c233e2dae86113f9f19b34f617edcfc8416f9bece671267bd1811b12111";
    };

    outputs = [ "out" "dev" ];

    meta = {
      description = "Simplified safe evaluation of Perl code";
      license = lib.licenses.mit;
    };
  };

  NeovimExt = perlPackages.buildPerlPackage {
    pname = "Neovim-Ext";
    version = "0.06";
    src = fetchurl {
      url = "mirror://cpan/authors/id/J/JA/JACQUESG/Neovim-Ext-0.06.tar.gz";
      sha256 = "6d2ceb3062c96737dba556cb20463130fc4006871b25b7c4f66cd3819d4504b8";
    };
    buildInputs = with perlPackages; [
      ArchiveZip
      FileSlurper
      FileWhich
      ProcBackground
      TestPod
      TestPodCoverage
    ];
    propagatedBuildInputs = with perlPackages; [
      ClassAccessor
      EvalSafe
      IOAsync
      MsgPackRaw
    ];

    # Attempts to download stuff from the internet.
    doCheck = false;

    outputs = [ "out" "dev" ];

    meta = {
      description = "Perl bindings for neovim";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  baseVimPackages = with vimPlugins; [
    #ale
    conjure
    elm-vim
    fugitive
    fzf-vim
    haskell-vim
    neoformat
    nvim-compe
    nvim-lspconfig
    nvim-tree-lua
    nvim-treesitter.withAllGrammars
    rust-vim
    telescope-fzf-native-nvim
    telescope-manix
    telescope-nvim
    todo-comments-nvim
    vimagit
    vim-gitgutter
    vim-go
    vim-hindent
    vim-lua
    vim-markdown
    vim-nix
    vim-ocaml
    vim-sleuth
    zig-vim

    neogen
    obsidian
    parchment
    vacme
  ];
  myVimPackages = baseVimPackages;
in
{
  environment.systemPackages = with pkgs; [
    nixpkgs-fmt
    elmPackages.elm
    elmPackages.elm-format
    elmPackages.elm-language-server
    fd
    fzf
    go
    gopls
    gotools
    haskellPackages.haskell-language-server
    haskellPackages.hindent
    luaformatter
    luajitPackages.lua-lsp
    manix
    nodejs
    nodePackages.prettier
    nodePackages.typescript-language-server
    perl
    perlPackages.PerlCritic
    perlPackages.PLS
    ripgrep
    rubyPackages.solargraph
    sumneko-lua-language-server
    tree-sitter
    zls

    NeovimExt
  ];
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      packages.myVimPackage = { start = myVimPackages; };
      customRC = ''
        " Restore cursor position
        autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif

        luafile ${./neovim.lua}
      '';
    };
  };
}
