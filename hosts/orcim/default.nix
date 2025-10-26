{
  pkgs,
  ...
}:
let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  hardware = {
    rtl-sdr.enable = true;
    bluetooth.enable = true;
    enableAllFirmware = true;
  };

  nixpkgs.config = {
    allowUnsupportedSystem = true;
    allowUnfree = true;
  };

  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  console.earlySetup = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPatches = [
      {
        name = "pwm-lpss";
        patch = null;
        extraConfig = ''
          PWM y
          PWM_LPSS m
          PWM_LPSS_PCI m
          PWM_LPSS_PLATFORM m
        '';
      }
    ];

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "fbcon=rotate:1"
      "gpd-pocket-fan.speed_on_ac=0"
      "video=DSI-1:panel_orientation=right_side_up"
    ];

    kernelModules = [
      "btusb"
      "kvm-intel"
      "i915"
      "pwm-lpss"
      "pwm-lpss-platform"
    ];

    initrd = {
      kernelModules = [
        "g_serial"
        "bq24190_charger"
        "i915"
        "pwm-lpss"
        "pwm-lpss-platform"
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

  networking = {
    hostName = "orcim";
    networkmanager.enable = true;
    wireless.userControlled.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      checkReversePath = "loose";
    };
  };

  environment.systemPackages = with pkgs; [
    isync
    mu
    rtl-sdr
    signal-desktop
  ];

  kdeMobile.enable = true;
  kdeConnect.enable = true;

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "qbit" ];
    };
    zsh = {
      shellInit = ''
        export OP_PLUGIN_ALIASES_SOURCED=1
      '';
      shellAliases = {
        "gh" = "op plugin run -- gh";
        "nixpkgs-review" =
          "env GITHUB_TOKEN=$(op item get nixpkgs-review --field token --reveal) nixpkgs-review";
        "godeps" = "go list -m -f '{{if not (or .Indirect .Main)}}{{.Path}}{{end}}' all";
        "sync-music" = "rsync -av --progress --delete ~/Music/ suah.dev:/var/lib/music/";
        "load-agent" =
          ''op item get signer --field 'private key' --reveal | sed '/"/d; s/\r//' | ssh-add -'';
      };
    };
  };

  services = {
    smartd.enable = false;
    fwupd = {
      enable = true;
    };
  };

  # pamu2fcfg -u qbit -opam://xin -ipam://orcim
  security.pam.u2f = {
    enable = true;
    settings = {
      origin = "pam://xin";
    };
  };

  users = {
    users = {
      root = {
        openssh.authorizedKeys.keys = pubKeys;
      };
      qbit = {
        openssh.authorizedKeys.keys = pubKeys;
        extraGroups = [
          "dialout"
          "libvirtd"
          "plugdev"
        ];
      };
    };
  };

  system.stateVersion = "22.11";
}
