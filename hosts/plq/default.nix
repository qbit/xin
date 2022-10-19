{ config, pkgs, emacs, isUnstable, ... }:
let
  secretAgent =
    "Contents/Library/LoginItems/SecretAgent.app/Contents/MacOS/SecretAgent";
  rage =
    pkgs.writeScriptBin "rage" (import ../../bins/rage.nix { inherit pkgs; });
in {
  _module.args.isUnstable = false;
  imports = [ ../../configs/tmux.nix ../../configs/zsh.nix ../../bins ];

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  networking.hostName = "plq";

  programs.zsh.enable = true;
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  services.emacs.package = pkgs.emacsUnstable;

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
    command =
      ''"/Users/qbit/Applications/Nix Apps/Secretive.app/${secretAgent}"'';
    serviceConfig = rec {
      KeepAlive = true;
      StandardErrorPath = StandardOutPath;
      StandardOutPath = "/Users/qbit/Library/Logs/SecretAgent.log";
    };
  };

  environment.variables = {
    SSH_AUTH_SOCK =
      "$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
  };

  environment.systemPackages = with pkgs; [
    (callPackage ../../pkgs/nheko.nix { inherit isUnstable; })
    (callPackage ../../pkgs/secretive.nix { inherit isUnstable; })

    nixpkgs-review
    direnv
    go
    mosh
    neovim
    nixfmt
    nmap
    rage
    statix
  ];
}

