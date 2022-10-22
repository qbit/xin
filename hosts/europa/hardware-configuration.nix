{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4b758b9b-4c75-4658-9649-64a2ceba2a0b";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-1f16b568-7726-44b6-b082-6b9d5e4d1972".device =
    "/dev/disk/by-uuid/1f16b568-7726-44b6-b082-6b9d5e4d1972";

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/F0A2-4A56";
    fsType = "vfat";
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware = {
    cpu.intel.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;
    video.hidpi.enable = lib.mkDefault true;
    bluetooth.enable = true;
  };
}
