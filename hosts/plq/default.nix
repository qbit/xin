{ config, pkgs, emacs, isUnstable, ... }:
let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFbj3DNho0T/SLcuKPzxT2/r8QNdEQ/ms6tRiX6YraJk root@tal.tapenet.org"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPMaAm4rDxyU975Z54YiNw3itC2fGc3SaE2VaS1fai8 root@box"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITjFpmWZVWixv2i9902R+g5B8umVhaqmjYEKs2nF3Lu qbit@tal.tapenet.org"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnaC1v+VoVNnK04D32H+euiCyWPXU8nX6w+4UoFfjA3 qbit@plq"
  ];
  userBase = { openssh.authorizedKeys.keys = pubKeys; };
  secretAgent =
    "Contents/Library/LoginItems/SecretAgent.app/Contents/MacOS/SecretAgent";
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

    nix-review
    direnv
    go
    mosh
    neovim
    nixfmt
    nmap
    statix
  ];
}

