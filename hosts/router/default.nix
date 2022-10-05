{ config, pkgs, ... }:
let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];
  userBase = { openssh.authorizedKeys.keys = pubKeys; };
in {
  _module.args.isUnstable = false;
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "router";

  networking.networkmanager.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.root = userBase;
  users.users.qbit = userBase;

  system.autoUpgrade.allowReboot = true;
  system.stateVersion = "22.05";
}

