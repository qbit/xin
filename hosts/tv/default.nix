{ pkgs
, config
, xinlib
, ...
}:
let
  inherit (xinlib) todo;
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ] ++ config.myconf.managementPubKeys;
  myKodi = pkgs.kodi.withPackages (kp: with kp; [
    certifi
    infotagger
    invidious
    jellyfin
    keymap
    sendtokodi
    somafm
  ]);
in
{
  _module.args.isUnstable = false;
  imports = [
    ./hardware-configuration.nix
    ../../configs/zsh.nix
    ../../configs/ssh.nix
  ];

  needsDeploy.enable = true;

  nixpkgs.config.permittedInsecurePackages = todo "tv using insecure youtube-dl!" [
    "python3.12-youtube-dl-2021.12.17"
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "snd-intel-dspcfg.dsp_driver=3" ];
  };

  myEmacs.enable = false;

  networking = {
    hostName = "tv";
    networkmanager.enable = true;
    wireless.userControlled.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      checkReversePath = "loose";
    };
    interfaces."enp0s13f0u4" = {
      wakeOnLan.enable = true;
    };
  };

  environment.sessionVariables = {
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
  };

  pipewire.enable = true;

  programs = {
    zsh.enable = true;
    ssh.package = pkgs.openssh;
  };

  services = {
    openssh.settings.UsePAM = true;
    avahi = {
      enable = true;
      publish = {
        enable = true;
        domain = true;
        addresses = true;
        workstation = true;
      };
    };
    openssh.settings.X11Forwarding = true;
    fwupd = {
      enable = true;
    };
    libinput.enable = true;
    xserver = {
      enable = true;
      desktopManager = {
        kodi = {
          enable = true;
          package = myKodi;
        };
      };
    };
    displayManager = {
      autoLogin = {
        user = "tv";
        enable = true;
      };
    };
  };

  users = {
    users = {
      root = {
        openssh.authorizedKeys.keys = pubKeys;
        shell = pkgs.zsh;
      };
      tv = {
        openssh.authorizedKeys.keys = pubKeys;
        shell = pkgs.zsh;
        isNormalUser = true;
        extraGroups = [ "dialout" "plugdev" "audio" ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
    alsa-utils
  ];

  hardware.firmware = with pkgs; [
    sof-firmware
  ];

  system = {
    stateVersion = "22.11";
  };
}
