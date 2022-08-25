{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [
    "nvme"
    "ehci_pci"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
    #rtl-sdr.enable = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/90420d7b-15a7-404b-b3cf-ac9a1bc418de";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4378-1665";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/5d0c92f0-c812-432f-a199-acce01673ffe"; }];

  nix.settings.max-jobs = lib.mkDefault 8;
}
