{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
    "/tmp" = {
      device = "/dev/disk/by-label/nix-extra";
      fsType = "ext4";
    };
  };

  hardware.enableRedistributableFirmware = true;

  hardware.deviceTree = {
    overlays = [
      "${pkgs.raspberrypifw}/share/raspberrypi/boot/overlays/rpi-ft5406.dtbo"
    ];
  };

  hardware.raspberry-pi."4".fkms-3d.enable = true;
}
