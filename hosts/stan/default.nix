{ config, pkgs, ... }:
let
  pubKeys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIA7khawMK6P0fXjhXXPEUTA2rF2tYB2VhzseZA/EQ/OtAAAAC3NzaDpncmVhdGVy qbit@litr.bold.daemon"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB1cBO17AFcS2NtIT+rIxR2Fhdu3HD4de4+IsFyKKuGQAAAACnNzaDpsZXNzZXI= qbit@litr.bold.daemon"
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBB/V8N5fqlSGgRCtLJMLDJ8Hd3JcJcY8skI0l+byLNRgQLZfTQRxlZ1yymRs36rXj+ASTnyw5ZDv+q2aXP7Lj0= hosts@secretive.plq.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
  ];

  userBase = { openssh.authorizedKeys.keys = pubKeys; };
in {
  _module.args.isUnstable = false;
  imports = [ ./hardware-configuration.nix ];

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
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "intel_idle.max_cstate=4" ];

  };

  preDNS.enable = false;
  networking = {
    hostName = "stan";
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 22 ];
      checkReversePath = "loose";
    };
  };

  i18n.defaultLocale = "en_US.utf8";

  kde.enable = true;
  defaultUsers.enable = false;

  sops.secrets = {
    tskey = {
      sopsFile = config.xin-secrets.stan.secrets;
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

  users.users.root = userBase;
  users.users.abieber = {
    isNormalUser = true;
    description = "Aaron Bieber";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [ ];
  };

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
    sshfs
    virt-manager
    wireshark
  ];

  virtualisation.libvirtd.enable = true;

  programs = {
    dconf.enable = true;
    zsh.enable = true;
  };

  services = {
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
