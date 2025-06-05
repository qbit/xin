{
  pkgs,
  lib,
  isUnstable,
  ...
}:
let
  secretAgent = "Contents/Library/LoginItems/SecretAgent.app/Contents/MacOS/SecretAgent";
  rage = pkgs.writeScriptBin "rage" (import ../../bins/rage.nix { inherit pkgs; });
in
{
  _module.args.isUnstable = false;
  imports = [
    ../../configs/tmux.nix
    ../../configs/zsh.nix
    ../../bins
  ];

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
  services = {
    emacs.package = pkgs.callPackage ../pkgs/emacs.nix { inherit isUnstable; };
  };

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    defaults = {
      dock.orientation = "left";
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    };
  };

  launchd.user.agents."SecretAgent" = {
    command = ''"/Users/qbit/Applications/Nix Apps/Secretive.app/${secretAgent}"'';
    serviceConfig = rec {
      KeepAlive = true;
      StandardErrorPath = StandardOutPath;
      StandardOutPath = "/Users/qbit/Library/Logs/SecretAgent.log";
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate =
      pkg:
      builtins.elm (lib.getName pkg) [
        "obsidian"
      ];
  };

  environment.variables = {
    SSH_AUTH_SOCK = "$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
  };

  environment.systemPackages = with pkgs; [
    (callPackage ../../pkgs/secretive.nix { inherit isUnstable; })
    (callPackage ../../pkgs/hammerspoon.nix { inherit isUnstable; })

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
    obsidian
    rage
    statix
  ];
  system.stateVersion = 5;
}
