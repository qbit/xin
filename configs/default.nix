{ inputs, ... }:
{
  imports = [
    ./ca.nix
    ./ci.nix
    ./colemak.nix
    ./develop.nix
    ./dns.nix
    ./doas.nix
    ./gitmux.nix
    ./git.nix
    ./neovim.nix
    ./peerix.nix
    ./manager.nix
    ./tmux.nix
    ./net-overlay.nix
    ./zsh.nix
  ];
}
