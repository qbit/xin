{ config
, lib
, modulesPath
, ...
}: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/4b758b9b-4c75-4658-9649-64a2ceba2a0b";
      fsType = "ext4";
    };
    "/run/media/qbit/backup" = {
      device = "/dev/disk/by-uuid/6e71eeea-6437-46f4-88d0-126c92af42ef";
      fsType = "ext4";
      label = "backup";
      neededForBoot = false;
    };
  };

  boot.initrd.luks.devices."luks-1f16b568-7726-44b6-b082-6b9d5e4d1972".device = "/dev/disk/by-uuid/1f16b568-7726-44b6-b082-6b9d5e4d1972";
  boot.initrd.luks.devices."luks-1f16b568-7726-44b6-b082-6b9d5e4d1972".crypttabExtraOpts = [ "fido2-device=auto" ];

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/F0A2-4A56";
    fsType = "vfat";
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware = {
    acpilight.enable = true;
    bluetooth.enable = true;
    cpu.intel.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;
    sensor = {
      iio.enable = true;
    };
    rtl-sdr.enable = true;
  };
}
