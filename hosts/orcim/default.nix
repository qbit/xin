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

  hardware = {
    rtl-sdr.enable = true;
  };

  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  console.earlySetup = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "fbcon=rotate:1"
      "gpd-pocket-fan.speed_on_ac=0"
      "video=DSI-1:panel_orientation=right_side_up"
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
    xserver = {
      dpi = 200;
      xrandrHeads = [{
        output = "DSI-1";
        primary = true;
        monitorConfig = ''
          Option  "Rotate"  "right"
        '';
      }];
    };
    power-profiles-daemon.enable = false;
    tlp = {
      enable = true;
      settings = {
        DISK_DEVICES = "mmcblk0";
        DISK_IOSCHED = "deadline";
        WIFI_PWR_ON_AC = false;
        WIFI_PWR_ON_BAT = false;
      };
    };
    fwupd = {
      enable = true;
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
