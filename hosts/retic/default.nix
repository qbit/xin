{ pkgs
, lib
, ...
}:
{
  _module.args.isUnstable = true;
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
  systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart =
    lib.mkForce [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
  services = {
    libinput.enable = true;
  };
  environment.systemPackages = with pkgs; [
    python3Packages.rns
    python3Packages.nomadnet
  ];

  system.stateVersion = "24.05";
}
