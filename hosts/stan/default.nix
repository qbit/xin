{ config, pkgs, ... }:
let
  pubKeys = [
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBB/V8N5fqlSGgRCtLJMLDJ8Hd3JcJcY8skI0l+byLNRgQLZfTQRxlZ1yymRs36rXj+ASTnyw5ZDv+q2aXP7Lj0= hosts@secretive.plq.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];

  userBase = { openssh.authorizedKeys.keys = pubKeys; };
  myEmacs = pkgs.callPackage ../../configs/emacs.nix { };
  peerixUser = if builtins.hasAttr "peerix" config.users.users then
    config.users.users.peerix.name
  else
    "root";
in {
  _module.args.isUnstable = true;
  imports = [ ./hardware-configuration.nix ../../overlays/default.nix ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };

    initrd = {
      luks.devices."luks-23b20980-eb1e-4390-b706-f0f42a623ddf".device =
        "/dev/disk/by-uuid/23b20980-eb1e-4390-b706-f0f42a623ddf";
      luks.devices."luks-23b20980-eb1e-4390-b706-f0f42a623ddf".keyFile =
        "/crypto_keyfile.bin";
      secrets = { "/crypto_keyfile.bin" = null; };
    };
    kernelParams = [ "intel_idle.max_cstate=4" ];
    kernelPackages = pkgs.linuxPackages;
  };

  preDNS.enable = false;
  networking = {
    hostName = "stan";

    hosts = {
      "172.16.30.253" = [ "proxmox-02.vm.calyptix.local" ];
      "127.0.0.1" = [ "borg.calyptix.dev" "localhost" ];
      "192.168.122.249" = [ "arst.arst" "vm" ];
    };

    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 22 ];
      checkReversePath = "loose";
    };
  };

  i18n.defaultLocale = "en_US.utf8";

  kde.enable = true;
  defaultUsers.enable = false;
  jetbrains.enable = true;
  sshFidoAgent.enable = true;

  sops.secrets = {
    tskey = {
      sopsFile = config.xin-secrets.stan.secrets;
      owner = "root";
      mode = "400";
    };
    vm_pass = {
      sopsFile = config.xin-secrets.stan.main;
      owner = "root";
      group = "wheel";
      mode = "400";
    };
    peerix_private_key = {
      sopsFile = config.xin-secrets.stan.peerix;
      owner = "${peerixUser}";
      group = "wheel";
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

  users.users.root = userBase;
  users.users.abieber = {
    isNormalUser = true;
    description = "Aaron Bieber";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [ ];
  } // userBase;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    barrier
    brave
    fzf
    google-chrome-dev
    ispell
    jitsi-meet-electron
    keychain
    matterhorn
    mosh
    mupdf
    nmap
    oathToolkit
    obs-studio
    openvpn
    rustdesk
    sshfs
    tcpdump
    virt-manager
    wireshark
    zig

    (callPackage ../../pkgs/zutty.nix { })
  ];

  virtualisation.libvirtd.enable = true;

  programs = {
    dconf.enable = true;
    zsh.enable = true;
  };

  tsPeerix = {
    enable = false;
    privateKeyFile = "${config.sops.secrets.peerix_private_key.path}";
    interfaces = [ "wlp170s0" "ztksevmpn3" ];
  };

  services = {
    emacs = {
      enable = false;
      package = myEmacs;
      install = true;
    };
    printing.enable = true;
    fwupd.enable = true;
    unifi.enable = true;
    openntpd.enable = true;
    resolved = {
      enable = true;
      dnssec = "allow-downgrade";
    };
  };

  system.stateVersion = "22.05"; # Did you read the comment?

}
