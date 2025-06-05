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
  _module.args.isUnstable = true;
  imports = [
    ./hardware-configuration.nix
  ];

  hardware.rtl-sdr.enable = true;

  boot = {
    loader.grub = {
      enable = true;
      devices = [
        "/dev/disk/by-id/wwn-0x5001b448be78d64a"
      ];
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };
  nixpkgs.config.allowUnsupportedSystem = true;

  networking = {
    hostName = "clunk";
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
    rofi
    rtl-sdr
    tncattach

    # no GLSL ES 3.10
    # (callPackage ../../pkgs/zutty.nix { })
  ];

  services = {
    fwupd = {
      enable = true;
    };

    libinput.enable = true;

    xserver = {
      enable = true;

      displayManager.lightdm.enable = true;

      deviceSection = ''
        Option "DRI" "2"
        Option "TearFree" "true"
      '';

      windowManager.xmonad = {
        enable = true;
        extraPackages =
          haskellPackages: with haskellPackages; [
            xmonad-contrib
            hostname
          ];
        config = builtins.readFile ./xmonad.hs;
      };
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

  system = {
    autoUpgrade.allowReboot = false;
    autoUpgrade.enable = false;
    stateVersion = "22.11";
  };
}
