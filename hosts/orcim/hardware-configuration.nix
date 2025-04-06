{ config, lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/hardware/network/broadcom-43xx.nix")
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      luks.devices."luks-035a7fbe-a187-47cb-90c0-ac4d0fea9b41".device = "/dev/disk/by-uuid/035a7fbe-a187-47cb-90c0-ac4d0fea9b41";
      availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_acpi" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/3705945c-a767-4380-a594-1f69fc463b26";
      fsType = "ext4";
    };



  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/C8DA-716C";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [
      { device = "/dev/disk/by-uuid/e729e069-f9ce-4a76-8710-b8dd16164e8f"; }
    ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
