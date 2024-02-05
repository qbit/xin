{ pkgs
, ...
}:
let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];
in
{
  _module.args.isUnstable = true;
  imports = [
    ./hardware-configuration.nix
  ];

  hardware.rtl-sdr.enable = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "gpd-pocket-fan.speed_on_ac=0"
      "fbcon=rotate:1"
    ];

    kernelModules = [ "btusb" "kvm-intel" ];

    initrd = {
      kernelModules = [
        "g_serial"
        "bq24190_charger"
        "i915"
      ];

      availableKernelModules = [
        "xhci_pci"
        "dm_mod"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sdhci_acpi"
        "sdhci_pci"
        "rtsx_pci_sdmmc"
      ];
    };

  };
  nixpkgs.config.allowUnsupportedSystem = true;

  networking = {
    hostName = "orcim";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      checkReversePath = "loose";
    };
  };

  environment.systemPackages = with pkgs; [
    alacritty
    direwolf
    polybar
    python3
    python3Packages.nomadnet
    python3Packages.rns
    rofi
    rtl-sdr
    tncattach
  ];

  kde.enable = true;

  services = {
    power-profiles-daemon.enable = false;
    tlp = {
      enable = true;
      extraConfig = ''
        DISK_DEVICES="mmcblk0"
        DISK_IOSCHED = "deadline"
        WIFI_PWR_ON_AC = off
        WIFI_PWR_ON_BAT = off
      '';
    };
    fwupd = {
      enable = true;
      enableTestRemote = true;
    };
  };

  users = {
    users = {
      root = { openssh.authorizedKeys.keys = pubKeys; };
      qbit = {
        openssh.authorizedKeys.keys = pubKeys;
        extraGroups = [ "dialout" "libvirtd" "plugdev" ];
      };
    };
  };

  system.stateVersion = "22.11";
}
