{ config, lib, options, pkgs, fetchFromGitHub, kernel, kmod, ... }:

let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBZExBj4QByLZSyKJ5+fPQnqDNrbsFz1IQWbFqCDcq9g qbit@ren.bold.daemon"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITjFpmWZVWixv2i9902R+g5B8umVhaqmjYEKs2nF3Lu qbit@tal.tapenet.org"
  ];

  userBase = { openssh.authorizedKeys.keys = pubKeys; };

in {
  _module.args.isUnstable = true;
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  buildConsumer.enable = true;

  boot.kernelModules = [ "vmm_clock" "virtio_vmmci" ];
  boot.extraModulePackages =
    [ pkgs.linuxPackages.vmm_clock pkgs.linuxPackages.virtio_vmmci ];
  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  networking.hostName = "nerm";

  # No IPv6
  networking.enableIPv6 = false;

  networking.useDHCP = false;
  networking.interfaces.enp0s2.useDHCP = false;
  networking.defaultGateway = "10.10.10.1";
  networking.interfaces.enp0s3.ipv4.addresses = [{
    address = "10.10.10.21";
    prefixLength = 24;
  }];

  nixpkgs.overlays = [
    (self: super:
      {
        #bitwarden_rs = unstable.bitwarden_rs;
      })
  ];

  environment.systemPackages = with pkgs; [
    ssb-patchwork
    signal-desktop
    neochat
  ];

  services = { openssh.forwardX11 = true; };

  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.root = userBase;
  users.users.qbit = userBase;

  system.stateVersion = "20.03";
}

