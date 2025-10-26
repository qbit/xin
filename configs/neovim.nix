{ pkgs, ... }:
with pkgs;
let
  vimBuildTool = pkgs.vimUtils.buildVimPlugin;

  vacme = vimBuildTool rec {
    pname = "vacme";
    # https://github.com/qbit/vacme
    version = "2017-01-14";
    src = pkgs.fetchFromGitHub {
      owner = "qbit";
      repo = pname;
      rev = "3715958cc23195e0224efe4cb5ba5cfe129bd592";
      hash = "sha256-vwqCa/iC01SY68seZ4/WarXDVjyi1FO5XHJglZr4l+8=";
    };
  };

  nofrils = vimBuildTool rec {
    pname = "nofrils";
    version = "unstable-2020-10-08";
    src = pkgs.fetchFromGitHub {
      owner = "robertmeta";
      repo = pname;
      rev = "bad6e490846e098866136ef20fff31e99f428bb9";
      hash = "sha256-BVBX2sFyTTqqgUmP0o77SKP1xrraJvCqkF+73rs0fLk=";
    };
  };

  baseVimPackages = with vimPlugins; [
    elm-vim
    fugitive
    fzf-vim
    haskell-vim
    neoformat
    neogit
    nvim-cmp
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
    vim-lua
    vim-markdown
    vim-nix
    vim-ocaml
    vim-sleuth
    zig-vim

    neogen
    vacme
    nofrils
  ];
  myVimPackages = baseVimPackages;
in
{
  environment.systemPackages = with pkgs; [
    djlint
    elmPackages.elm
    elmPackages.elm-format
    elmPackages.elm-language-server
    fd
    fzf
    go
    gopls
    gotools
    haskellPackages.haskell-language-server
    htmx-lsp
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
