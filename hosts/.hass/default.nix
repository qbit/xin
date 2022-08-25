{ config, pkgs, ... }:
let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFbj3DNho0T/SLcuKPzxT2/r8QNdEQ/ms6tRiX6YraJk root@tal.tapenet.org"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPMaAm4rDxyU975Z54YiNw3itC2fGc3SaE2VaS1fai8 root@box"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITjFpmWZVWixv2i9902R+g5B8umVhaqmjYEKs2nF3Lu qbit@tal.tapenet.org"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnaC1v+VoVNnK04D32H+euiCyWPXU8nX6w+4UoFfjA3 qbit@plq"
  ];
  userBase = { openssh.authorizedKeys.keys = pubKeys; };
in {
  _module.args.isUnstable = false;
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #boot.supportedFilesystems = [ "zfs" ];
  #boot.zfs.devNodes = "/dev/";

  networking.hostName = "hass";
  networking.hostId = "cd47baaf";

  networking.useDHCP = false;
  #networking.interfaces.enp1s0.useDHCP = true;
  #networking.interfaces.enp2s0.useDHCP = true;

  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.root = userBase;
  users.users.qbit = userBase;

  dnsOverTLS.enable = true;
  system.stateVersion = "22.05"; # Did you read the comment?
}

