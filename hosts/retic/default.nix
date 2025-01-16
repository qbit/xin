{ pkgs
, ...
}:
let
  checkKillAll = p: (_: super: {
    "${p}" = super."${p}".overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
      checkPhase = "";
    });
  });
  checkKill = p: (_: super: {
    "${p}" = super."${p}".overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
      checkPhase = "";
    });
  });
in
{
  _module.args.isUnstable = false;
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.overlays = [
    (checkKill "boehmgc")
    (checkKill "libuv")
    (checkKillAll "llvm")
    (checkKill "elfutils")
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
