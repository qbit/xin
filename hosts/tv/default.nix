{ pkgs
, config
, ...
}:
let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ] ++ config.myconf.managementPubKeys;
  myKodi = pkgs.kodi.withPackages (kp: with kp; [
    certifi
    infotagger
    invidious
    jellycon
    jellyfin
    requests
    somafm
  ]);
in
{
  _module.args.isUnstable = true;
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
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

  environment.sessionVariables = {
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
  };

  services = {
    fwupd = {
      enable = true;
    };

    xserver = {
      libinput.enable = true;
      enable = true;
      desktopManager = {
        kodi = {
          enable = true;
          package = myKodi;
        };

      };
      displayManager = {
        autoLogin = {
          user = "tv";
          enable = true;
        };
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
