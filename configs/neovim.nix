{ pkgs, ... }:
with pkgs;
let
  parchment = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "parchment";
    version = "0.4.0";
    src = pkgs.fetchFromGitHub {
      owner = "ajgrf";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-ZphConCGZR3EG6dd8Ji7U9Qtm21SoWMk60XD4X+My1g=";
    };
  };
  vacme = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "vacme";
    version = "2017-01-14";
    src = pkgs.fetchFromGitHub {
      owner = "olivertaylor";
      repo = pname;
      rev = "2f0b284b5bc1c9dd5b7f0b89ac880959e61b0be4";
      sha256 = "sha256-eea0Ntr3gCmF6iZ0adZaVswWH70K9IJZ4SAyVSdFp3E=";
    };
  };
  obsidian = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "obsidian-nvim";
    version = "1.7.0"; # 1.8.0 has breaking changes
    src = pkgs.fetchFromGitHub {
      owner = "epwalsh";
      repo = "obsidian.nvim";
      rev = "v${version}";
      sha256 = "sha256-pMYvtNEYoVFaWlj35F1rDlfJkNY4y4S62RNpHBNBgto=";
      fetchSubmodules = true;
    };
    dependencies = with vimPlugins; [ nvim-cmp tabular ];
  };
  neogen = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
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
  baseVimPackages = with vimPlugins; [
    fugitive
    fzf-vim
    nvim-compe
    nvim-lspconfig
    nvim-tree-lua
    rust-vim
    telescope-fzf-native-nvim
    telescope-nvim
    vimagit
    vim-gitgutter
    vim-lua
    vim-markdown
    vim-nix
    vim-ocaml
    zig-vim
    nvim-treesitter.withAllGrammars

    neogen
    obsidian
    parchment
    vacme
  ];
  myVimPackages = if pkgs.system == "aarch64-linux" then
    baseVimPackages
  else
    baseVimPackages ++ [ vimPlugins.vim-go vimPlugins.telescope-manix ];
in {
  environment.systemPackages = with pkgs; [
    fzf
    go
    gopls
    gotools
    luaformatter
    manix
    ripgrep
    luajitPackages.lua-lsp
    rubyPackages.solargraph
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
