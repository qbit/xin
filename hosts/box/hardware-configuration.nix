{ ... }: {
  boot = {
    initrd = {
      availableKernelModules = [ "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" "wireguard" ];
    extraModulePackages = [ ];
  };

  hardware.enableRedistributableFirmware = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/248dfcf7-999b-4dba-bfbf-0b10dbb376b1";
      fsType = "ext4";
    };

    "/external" = {
      device = "/dev/disk/by-uuid/e73b7f14-a921-4d06-813a-0655583d8948";
      fsType = "ext4";
    };

    "/home" = {
      device = "rpool/home";
      fsType = "zfs";
    };

    "/backups" = {
      device = "rpool/backups";
      fsType = "zfs";
    };

    "/media/music" = {
      device = "rpool/media/music";
      fsType = "zfs";
    };

    "/media/movies" = {
      device = "rpool/media/movies";
      fsType = "zfs";
    };

    "/media/pictures" = {
      device = "rpool/pictures";
      fsType = "zfs";
    };

    "/media/tv" = {
      device = "rpool/media/tv";
      fsType = "zfs";
    };

    "/media/nextcloud" = {
      device = "rpool/nextcloud";
      fsType = "zfs";
    };

    "/media/naughty" = {
      device = "rpool/media/naughty";
      fsType = "zfs";
    };

    "/media/git" = {
      device = "rpool/git";
      fsType = "zfs";
    };

    "/media/downloads" = {
      device = "rpool/downloads";
      fsType = "zfs";
    };

    "/db/postgres" = {
      device = "rpool/db/postgres";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/2AC3-DB6C";
      fsType = "vfat";
    };
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/97d6ef56-ea18-493b-aac0-e58e773ced30"; }];
}
