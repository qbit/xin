{ config, lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/hardware/network/broadcom-43xx.nix")
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      luks.devices.crypted.device = "/dev/disk/by-uuid/5be7f5d5-3172-4058-b9c1-93376758f4c0";
      availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_acpi" ];
      kernelModules = [ "dm-snapshot" ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/c22ae62d-e66d-42fa-9892-d4b8fbb1e6f4";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/E1A0-9ACF";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [
      { device = "/dev/disk/by-uuid/e3cf51f7-1856-429c-baab-c7c07e3dc6cc"; }
    ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
