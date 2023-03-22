{ ... }:

{
  boot.initrd.availableKernelModules =
    [ "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "wireguard" ];
  boot.extraModulePackages = [ ];

  hardware.enableRedistributableFirmware = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/248dfcf7-999b-4dba-bfbf-0b10dbb376b1";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "rpool/home";
    fsType = "zfs";
  };

  fileSystems."/backups" = {
    device = "rpool/backups";
    fsType = "zfs";
  };

  fileSystems."/media/music" = {
    device = "rpool/media/music";
    fsType = "zfs";
  };

  fileSystems."/media/movies" = {
    device = "rpool/media/movies";
    fsType = "zfs";
  };

  fileSystems."/media/pictures" = {
    device = "rpool/pictures";
    fsType = "zfs";
  };

  fileSystems."/media/tv" = {
    device = "rpool/media/tv";
    fsType = "zfs";
  };

  fileSystems."/media/nextcloud" = {
    device = "rpool/nextcloud";
    fsType = "zfs";
  };

  fileSystems."/media/git" = {
    device = "rpool/git";
    fsType = "zfs";
  };

  fileSystems."/media/downloads" = {
    device = "rpool/downloads";
    fsType = "zfs";
  };

  fileSystems."/db/postgres" = {
    device = "rpool/db/postgres";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2AC3-DB6C";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/97d6ef56-ea18-493b-aac0-e58e773ced30"; }];
}
