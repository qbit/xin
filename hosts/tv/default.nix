{ pkgs
, ...
}:
let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];
  myKodi = pkgs.kodi.withPackages (kp: [
    kp.somafm
    kp.jellyfin
    kp.invidious
  ]);
in
{
  _module.args.isUnstable = false;
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader.grub = {
      enable = true;
      devices = [
        "/dev/disk/by-id/wwn-0x5001b448be78d64a"
      ];
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    hostName = "tv";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      checkReversePath = "loose";
    };
  };

  services = {
    fwupd = {
      enable = true;
    };

    xserver = {
      libinput.enable = true;
      enable = true;
      desktopManager.kodi = {
        enable = true;
        package = myKodi;
      };
      videoDrivers = [ "intel" ];
    };
  };

  users = {
    users = {
      root = { openssh.authorizedKeys.keys = pubKeys; };
      tv = {
        openssh.authorizedKeys.keys = pubKeys;
        isNormalUser = true;
      };
    };
  };

  system = {
    stateVersion = "22.11";
  };
}
