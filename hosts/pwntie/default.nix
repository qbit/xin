{ config, pkgs, lib, xinlib, ... }:

let
  myEmacs = pkgs.callPackage ../../configs/emacs.nix { };
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];
in {
  _module.args.isUnstable = true;
  imports = [ ./hardware-configuration.nix ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking = {
    hostName = "pwntie";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      checkReversePath = "loose";
    };
  };

  virtualisation.libvirtd.enable = true;

  environment.sessionVariables = {
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_DATA_HOME = "\${HOME}/.local/share";

    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\${HOME}/.steam/root/compatibilitytools.d";
    PATH = [ "\${XDG_BIN_HOME}" ];
  };

  kde.enable = true;
  users.users.qbit.extraGroups = [ "dialout" "libvirtd" "docker" ];

  nixpkgs.config.allowUnfree = true;

  programs = {
    steam.enable = true;
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "qbit" ];
    };
    dconf.enable = true;
  };

  xinCI = {
    user = "qbit";
    enable = true;
  };

  services = {
    emacs = {
      enable = true;
      package = myEmacs;
      install = true;
    };
    fwupd = {
      enable = true;
      enableTestRemote = true;
    };

  };

  users.users.root = { openssh.authorizedKeys.keys = pubKeys; };

  system.stateVersion = "22.11";
}
