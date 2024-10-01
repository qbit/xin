{ pkgs
, ...
}:
{
  _module.args.isUnstable = true;
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.overlays = [
    (_: super: {
      boehmgc = super.boehmgc.overrideAttrs (_: {
        doCheck = false;
      });
    })
    (_: super: {
      libuv = super.libuv.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];

  myEmacs.enable = false;

  boot = {
    initrd.availableKernelModules = [ "usbhid" "usb_storage" "vc4" ];
    kernelPackages = pkgs.linuxPackages;
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
