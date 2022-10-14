{ config, pkgs, ... }:
let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];
  userBase = { openssh.authorizedKeys.keys = pubKeys; };
in {
  _module.args.isUnstable = false;
  imports = [ ./hardware-configuration.nix ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "router";

  networking.networkmanager.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.root = userBase;
  users.users.qbit = userBase;

  system.autoUpgrade.allowReboot = true;
  system.stateVersion = "22.05";
}

