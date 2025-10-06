{
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
      luks.devices."luks-e12e4b82-6f9e-4f80-b3f4-7e9a248e7827".device =
        "/dev/disk/by-uuid/e12e4b82-6f9e-4f80-b3f4-7e9a248e7827";
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  system.fsPackages = [ pkgs.sshfs ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/56138f23-38c0-4e4f-8dee-4fcd57c238a0";
      fsType = "ext4";
    };
    "/boot/efi" = {
      device = "/dev/disk/by-uuid/4CFA-E61D";
      fsType = "vfat";
    };
    "/home/abieber/aef100" = {
      device = "vm:aef100/";
      fsType = "sshfs";
      options = [
        "_netdev"
        "x-systemd.automount"

        (builtins.replaceStrings [ " " ] [ "\\040" ]
          "ssh_command=${pkgs.openssh}/bin/ssh -F /home/abieber/.ssh/config"
        )
        "reconnect"
        "allow_other"
        "cache=yes"
        "auto_cache"

        "ServerAliveInterval=15"
        "IdentityFile=/home/abieber/.ssh/vm"
      ];
    };
    "/home/abieber/cxos-1211" = {
      device = "cxos:src/";
      fsType = "sshfs";
      options = [
        "_netdev"
        "x-systemd.automount"

        (builtins.replaceStrings [ " " ] [ "\\040" ]
          "ssh_command=${pkgs.openssh}/bin/ssh -F /home/abieber/.ssh/config"
        )
        "reconnect"
        "allow_other"
        "cache=yes"
        "auto_cache"

        "ServerAliveInterval=15"
        "IdentityFile=/home/abieber/.ssh/vm"
      ];
    };
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/85a3b559-0c0f-485d-9107-9f6ba5ad31da"; } ];

  networking.useDHCP = lib.mkDefault true;

  hardware = {
    bluetooth.enable = true;
    rtl-sdr.enable = true;
  };
}
