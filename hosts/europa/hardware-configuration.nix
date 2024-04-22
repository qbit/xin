{ config, lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
      luks.devices."luks-e8368ac8-9b9c-496f-bb19-0d1911070140".device = "/dev/disk/by-uuid/e8368ac8-9b9c-496f-bb19-0d1911070140";
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" =
      {
        device = "/dev/disk/by-uuid/0b946ca0-f0cb-4e54-bc73-d2afe6b328d2";
        fsType = "ext4";
      };
    "/boot" =
      {
        device = "/dev/disk/by-uuid/3D38-3AEC";
        fsType = "vfat";
        options = [ "fmask=0022" "dmask=0022" ];
      };

    "/run/media/qbit/backup" = {
      device = "/dev/disk/by-uuid/6e71eeea-6437-46f4-88d0-126c92af42ef";
      fsType = "ext4";
      label = "backup";
      neededForBoot = false;
    };
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/1c2bb5e0-7ca8-4943-8e0f-527497ce2d61"; }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware = {
    bluetooth.enable = true;
    rtl-sdr.enable = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
