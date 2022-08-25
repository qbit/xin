{ config, lib, pkgs, ... }:
with pkgs;
let
  baseVimPackages = with vimPlugins; [
    fugitive
    nvim-compe
    nvim-lspconfig
    vim-gitgutter
    vim-nix
    zig-vim
    vimagit
    rust-vim
  ];
  myVimPackages = if pkgs.system == "aarch64-linux" then
    baseVimPackages
  else
    baseVimPackages ++ [ vimPlugins.vim-go ];
in {
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
