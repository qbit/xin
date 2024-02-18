{ pkgs, ... }:
with pkgs;
let
  vimBuildTool = pkgs.vimUtils.buildVimPlugin;

  vacme = vimBuildTool rec {
    pname = "vacme";
    # https://github.com/overvale/vacme (archived)
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
    # https://github.com/epwalsh/obsidian.nvim/tags
    version = "3.2.0";
    src = pkgs.fetchFromGitHub {
      owner = "epwalsh";
      repo = "obsidian.nvim";
      rev = "v${version}";
      sha256 = "sha256-VIc5qgzqJjSv2A0v8tM25pWh+smX9DYXVsyFNTGMPbQ=";
      fetchSubmodules = true;
    };
    dependencies = with vimPlugins; [
      nvim-cmp
      tabular
      plenary-nvim
    ];
  };

  baseVimPackages = with vimPlugins; [
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
    vacme
  ];
  myVimPackages = baseVimPackages;
in
{
  environment.systemPackages = with pkgs; [
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
    nixpkgs-fmt
    nodejs
    nodePackages.prettier
    nodePackages.typescript-language-server
    perl
    perlPackages.NeovimExt
    perlPackages.PerlCritic
    perlPackages.PLS
    ripgrep
    rubyPackages.solargraph
    sleek
    sumneko-lua-language-server
    tree-sitter
    zls
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      packages.myVimPackage = {
        start = myVimPackages;
      };
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
