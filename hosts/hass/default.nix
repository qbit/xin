{ config, pkgs, ... }:
let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPMaAm4rDxyU975Z54YiNw3itC2fGc3SaE2VaS1fai8 root@box"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnaC1v+VoVNnK04D32H+euiCyWPXU8nX6w+4UoFfjA3 qbit@plq"
  ];
  userBase = { openssh.authorizedKeys.keys = pubKeys; };
in {
  _module.args.isUnstable = false;
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.supportedFilesystems = [ "zfs" ];
  #boot.zfs.devNodes = "/dev/";

  networking.hostName = "hass";
  networking.hostId = "cd47baaf";

  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.eno2.useDHCP = true;

  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.root = userBase;
  users.users.qbit = userBase;

  services = {
    fwupd = {
      enable = true;
      enableTestRemote = true;
    };
  };

  preDNS.enable = true;
  system.stateVersion = "22.05"; # Did you read the comment?
}

