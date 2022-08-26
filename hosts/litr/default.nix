{ config, pkgs, lib, ... }:

let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITjFpmWZVWixv2i9902R+g5B8umVhaqmjYEKs2nF3Lu qbit@tal.tapenet.org"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIA7khawMK6P0fXjhXXPEUTA2rF2tYB2VhzseZA/EQ/OtAAAAC3NzaDpncmVhdGVy qbit@litr.bold.daemon"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB1cBO17AFcS2NtIT+rIxR2Fhdu3HD4de4+IsFyKKuGQAAAACnNzaDpsZXNzZXI= qbit@litr.bold.daemon"
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBB/V8N5fqlSGgRCtLJMLDJ8Hd3JcJcY8skI0l+byLNRgQLZfTQRxlZ1yymRs36rXj+ASTnyw5ZDv+q2aXP7Lj0= hosts@secretive.plq.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];

  userBase = { openssh.authorizedKeys.keys = pubKeys; };

in {
  _module.args.isUnstable = true;
  imports = [ ./hardware-configuration.nix ../../overlays/default.nix ];

  doas.enable = true;
  kde.enable = true;
  jetbrains.enable = true;
  sshFidoAgent.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "litr";
  networking.hosts."172.16.30.253" = [ "proxmox-02.vm.calyptix.local" ];
  networking.hosts."127.0.0.1" = [ "borg.calyptix.dev" "localhost" ];
  networking.hosts."192.168.122.133" = [ "arst.arst" "vm" ];

  networking.networkmanager.enable = true;

  preDNS.enable = false;

  sops.secrets = {
    tskey = {
      sopsFile = config.xin-secrets.litr.secrets;
      owner = "root";
      mode = "400";
    };
  };

  systemd.services = {
    "tailscale-init" = {
      wantedBy = [ "tailscaled.service" ];
      after = [ "tailscaled.service" ];
      serviceConfig = {
        ExecStart =
          "${pkgs.tailscale}/bin/tailscale up --auth-key file://${config.sops.secrets.tskey.path}";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    arcanPackages.all-wrapped
    aircrack-ng
    apg
    barrier
    firefox
    fzf
    gnome.gnome-keyring
    ispell
    jitsi-meet-electron
    keychain
    kismet
    matterhorn
    mercurial
    mosh
    mupdf
    nfs-utils
    nmap
    nodejs
    notejot
    oathToolkit
    obs-studio
    openvpn
    rbw
    rust-analyzer
    silver-searcher
    sshfs
    tcpdump
    teams
    tor
    uucp
    vlc
    vscode
    wireshark
    virt-manager

    google-chrome-dev
  ];

  nixpkgs.config.allowUnfree = true;

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  services = {
    fwupd.enable = true;
    unifi.enable = true;
    openntpd.enable = true;
    resolved = {
      enable = true;
      dnssec = "allow-downgrade";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 22 ];
    checkReversePath = "loose";
  };

  users.users.root = userBase;
  users.users.abieber = userBase // {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
  };

  programs.zsh.enable = true;

  system.stateVersion = "20.03"; # Did you read the comment?
}

