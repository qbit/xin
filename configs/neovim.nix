{ config, lib, pkgs, ... }:
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
  mind = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "mind.nvim";
    version = "2.2.1";
    src = pkgs.fetchFromGitHub {
      owner = "phaazon";
      repo = pname;
      rev = "79e0ca131d5e37dfa65f3f0e725d99742e4ff783";
      sha256 = "sha256-y64F9v7Ggzagmz2p2EYTdtKDuGyA19xYXqW92S0tRj0=";
    };
    nativeBuildBuildInputs = with vimPlugins; [
      plenary-nvim
    ];
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
    vim-nix
    vim-ocaml
    zig-vim

    parchment
    vacme
    mind
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
    sumneko-lua-language-server
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
