{ config, pkgs, lib, modulesPath, ... }:
let
  myEmacs = pkgs.callPackage ../../configs/emacs.nix { };
  peerixUser = if builtins.hasAttr "peerix" config.users.users then
    config.users.users.peerix.name
  else
    "root";
in {
  _module.args.isUnstable = true;

  imports =
    [ ./hardware-configuration.nix ../../pkgs ../../configs/neomutt.nix ];

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
    netrc = {
      sopsFile = config.xin-secrets.europa.qbit;
      owner = "qbit";
      group = "wheel";
      mode = "400";
    };
    peerix_private_key = {
      sopsFile = config.xin-secrets.europa.peerix;
      owner = "${peerixUser}";
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
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
    kernelParams = [ "boot.shell_on_fail" "mem_sleep_default=deep" ];
    kernelPackages = pkgs.linuxPackages;
    kernelModules = [ "kvm-intel" ];
  };

  programs.zsh.shellAliases = {
    "nixpkgs-review" =
      "GITHUB_TOKEN=$(cat /run/secrets/nix_review) nixpkgs-review";
    "neomutt" = "neomutt -F /etc/neomuttrc";
    "mutt" = "neomutt -F /etc/neomuttrc";
  };

  sshFidoAgent.enable = true;

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
    enable = false;
    privateKeyFile = "${config.sops.secrets.peerix_private_key.path}";
    interfaces = [ "wlp170s0" "ztksevmpn3" ];
  };

  programs.steam.enable = true;

  services = {
    clamav.updater.enable = true;
    emacs = {
      enable = true;
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
        "*/2 * * * *  qbit  . /etc/profile; (cd ~/Brain && git sync) >/dev/null 2>&1"
        "*/5 * * * *  qbit  . /etc/profile; (cd ~/org && git sync) >/dev/null 2>&1"
        "*/30 * * * *  qbit  . /etc/profile; taskobs"
      ];
    };

    fwupd = {
      enable = true;
      enableTestRemote = true;
    };

    udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="5bf0", GROUP="users", TAG+="uaccess"
    '';
  };

  users.users.qbit.extraGroups = [ "dialout" "libvirtd" ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    arcanPackages.all-wrapped
    barrier
    calibre
    cider
    clementine
    drawterm
    element-desktop
    cinny-desktop
    exercism
    fido2luks
    isync
    klavaro
    linphone
    logseq
    minicom
    mu
    nheko
    nix-index
    nixpkgs-review
    nix-top
    nmap
    obsidian
    pharo
    pharo-launcher
    rofi
    signal-desktop
    taskobs
    tcpdump
    tidal-hifi
    tigervnc
    unzip
    virt-manager
    yt-dlp
    zig

    (callPackage ../../pkgs/zutty.nix { })

  ];

  # for Pharo
  security.pam.loginLimits = [
    {
      domain = "qbit";
      type = "hard";
      item = "rtprio";
      value = "2";
    }
    {
      domain = "qbit";
      type = "soft";
      item = "rtprio";
      value = "2";
    }
  ];

  system.autoUpgrade.allowReboot = false;
  system.stateVersion = "21.11";
}
