{ config, pkgs, lib, modulesPath, ... }:
let myEmacs = pkgs.callPackage ../../configs/emacs.nix { };
in {
  _module.args.isUnstable = true;

  imports = [
    ./hardware-configuration.nix
    ../../pkgs
    ../../configs/neomutt.nix
    ../../overlays/default.nix
  ];

  sops.secrets = {
    fastmail = {
      sopsFile = config.xin-secrets.europa.qbit;
      owner = "qbit";
      group = "wheel";
      mode = "400";
    };
    fastmail_user = {
      sopsFile = config.xin-secrets.europa.qbit;
      owner = "qbit";
      group = "wheel";
      mode = "400";
    };
    nix_review = {
      sopsFile = config.xin-secrets.europa.qbit;
      owner = "qbit";
      group = "wheel";
      mode = "400";
    };
    peerix_private_key = {
      sopsFile = config.xin-secrets.europa.peerix;
      owner = "peerix";
      group = "wheel";
      mode = "400";
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nixpkgs.config.allowUnsupportedSystem = true;

  boot = {
    initrd.availableKernelModules =
      [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" ];
    initrd.kernelModules = [ ];
    extraModulePackages = [ ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages;
    kernelParams = [ "boot.shell_on_fail" ];
    kernelModules = [ "kvm-intel" ];
  };

  programs.zsh.shellAliases = {
    "nix-review" = "GITHUB_TOKEN=$(cat /run/secrets/nix_review) nix-review";
    "neomutt" = "neomutt -F /etc/neomuttrc";
    "mutt" = "neomutt -F /etc/neomuttrc";
  };

  sshFidoAgent.enable = true;
  configManager = {
    enable = true;
    router = {
      enable = true;

      hostName = "10.6.0.1";
      pfAllowUnifi = false;

      interfaces = {
        em0 = {
          text = ''
            inet autoconf
            inet6 autoconf
          '';
        };
        em1 = {
          text = ''
            inet 10.99.99.1 255.255.255.0 10.99.99.255
            description "Trunk"
            up
          '';
        };
        vlan2 = {
          text = ''
            inet 10.3.0.1 255.255.255.0 10.3.0.255 vnetid 2 parent em1 description "Lab" up'';
        };
        vlan10 = {
          text = ''
            inet 10.10.0.1 255.255.255.0 10.10.0.255 vnetid 10 parent em1 description "Untrusted WiFi" up'';
        };
        vlan11 = {
          text = ''
            inet 10.12.0.1 255.255.255.0 10.12.0.255 vnetid 11 parent em1 description "Trusted WiFi" up'';
        };
      };
    };
  };

  nixManager = {
    enable = true;
    user = "qbit";
  };

  kde.enable = true;
  jetbrains.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  networking.hosts."100.120.151.126" = [ "graph.tapenet.org" ];
  networking = {
    hostName = "europa";
    hostId = "87703c3e";
    wireless.userControlled.enable = true;
    networkmanager.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      checkReversePath = "loose";
    };
  };

  tsPeerix = {
    enable = true;
    privateKeyFile = "${config.sops.secrets.peerix_private_key.path}";
  };

  programs.steam.enable = true;
  services = {
    emacs = {
      enable = false;
      package = myEmacs;
      install = true;
    };
    tor = {
      enable = true;
      client.enable = true;
    };
    cron = {
      enable = true;
      systemCronJobs = [
        "*/2 * * * *  qbit  . /etc/profile; (cd ~/Notes && git sync) >/dev/null 2>&1"
        "*/5 * * * *  qbit  . /etc/profile; (cd ~/org && git sync) >/dev/null 2>&1"
      ];
    };
    fprintd.enable = true;
    #logind = {
    #  lidSwitch = "suspend-then-hibernate";
    #  lidSwitchExternalPower = "lock";
    #};
    fstrim.enable = true;
    tlp = {
      enable = false;
      settings = {
        CPU_BOOST_ON_BAT = 0;
        CPU_SCALING_GOVERNOR_ON_BATTERY = "powersave";
        START_CHARGE_THRESH_BAT0 = 90;
        STOP_CHARGE_THRESH_BAT0 = 97;
        RUNTIME_PM_ON_BAT = "auto";
      };
    };
    fwupd = {
      enable = true;
      enableTestRemote = true;
    };

    udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="5bf0", GROUP="users", TAG+="uaccess"
    '';
  };

  users.users.qbit.extraGroups = [ "libvirtd" ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    arcanPackages.all-wrapped
    barrier
    cider
    drawterm
    element-desktop
    exercism
    isync
    klavaro
    libfprint-2-tod1-goodix
    linphone
    logseq
    mu
    nheko
    nix-index
    nix-review
    nix-top
    rofi
    signal-desktop
    thunderbird
    tidal-hifi
    tigervnc
    virt-manager
    yt-dlp
  ];

  system.stateVersion = "21.11";
}

