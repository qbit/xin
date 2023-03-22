# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/56138f23-38c0-4e4f-8dee-4fcd57c238a0";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-e12e4b82-6f9e-4f80-b3f4-7e9a248e7827".device =
    "/dev/disk/by-uuid/e12e4b82-6f9e-4f80-b3f4-7e9a248e7827";

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/4CFA-E61D";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/85a3b559-0c0f-485d-9107-9f6ba5ad31da"; }];

  networking.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.video.hidpi.enable = lib.mkDefault false;
  hardware.bluetooth.enable = true;
}
