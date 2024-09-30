{ pkgs
, ...
}:
{
  _module.args.isUnstable = false;
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    initrd.availableKernelModules = [ "usbhid" "usb_storage" "vc4" ];
    kernelPackages = pkgs.linuxPackages;
    #kernelModules = [ "raspberrypi_ts" "rtc-ds3232" "rtc-ds1307" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  networking = {
    hostName = "retic";
  };

  preDNS.enable = false;

  environment.systemPackages = with pkgs; [
    python3Packages.rns
    python3Packages.nomadnet
  ];

  system.stateVersion = "24.05";
}
