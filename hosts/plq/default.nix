{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  rage = pkgs.writeScriptBin "rage" (import ../../bins/rage.nix { inherit pkgs; });
in
{
  imports = [
    ../../configs/tmux.nix
    ../../configs/zsh.nix
    ../../configs/emacs.nix
    ../../bins
  ];

  nixpkgs.overlays = [
    inputs.emacs-overlay.overlay
  ];

  myEmacs.enable = true;

  networking.hostName = "plq";

  security.pam.services.sudo_local.touchIdAuth = true;

  programs = {
    zsh = {
      enable = true;
      shellInit = ''
        export OP_PLUGIN_ALIASES_SOURCED=1
      '';
    };
  };
  nix = {
    package = pkgs.nix;
    settings = {
      sandbox = true;
    };
  };

  system = {
    primaryUser = "qbit";
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    defaults = {
      dock.orientation = "left";
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate =
      pkg:
      builtins.elm (lib.getName pkg) [
      ];
  };

  environment.systemPackages = with pkgs; [
    direnv
    exiftool
    gh
    gnupg
    go
    mosh
    nb
    neovim
    nixpkgs-review
    nmap
    rage
    statix
  ];

  ids.gids.nixbld = 30000;

  system.stateVersion = 5;
}
