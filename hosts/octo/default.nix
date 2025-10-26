{
  config,
  pkgs,
  lib,
  ...
}:
let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7v+/xS8832iMqJHCWsxUZ8zYoMWoZhjj++e26g1fLT europa"
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBB/V8N5fqlSGgRCtLJMLDJ8Hd3JcJcY8skI0l+byLNRgQLZfTQRxlZ1yymRs36rXj+ASTnyw5ZDv+q2aXP7Lj0= hosts@secretive.plq.local"
  ];
  userBase = {
    openssh.authorizedKeys.keys = pubKeys ++ config.myconf.managementPubKeys;
  };
in
{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    initrd.availableKernelModules = [
      "usbhid"
      "usb_storage"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "raspberrypi_ts" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  networking = {
    hostName = "octo";
    networkmanager = {
      enable = true;
    };
    wireless.userControlled.enable = true;
  };

  preDNS.enable = false;
  systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pkgs.networkmanager}/bin/nm-online -q"
  ];

  users.users = {
    root = userBase;
    qbit = userBase;
  };

  services.octoprint = {
    enable = true;
    openFirewall = true;
  };

  system.stateVersion = "21.11";
}
