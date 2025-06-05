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
  _module.args.isUnstable = false;
  imports = [
    ./hardware-configuration.nix
  ];

  defaultUsers.enable = false;

  boot = {
    initrd.availableKernelModules = lib.mkForce [
      "mmc_block"
      "usbhid"
      "hid_generic"
      "hid_microsoft"
    ];

    supportedFilesystems = lib.mkForce [ "vfat" ];

    kernelPackages = lib.mkForce pkgs.linuxPackages_rpi0;
  };

  networking = {
    hostName = "wzero";
    networkmanager = {
      enable = true;
    };
    wireless.userControlled.enable = true;
    hosts."100.120.151.126" = [ "graph.tapenet.org" ];
  };

  users.users.weather = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Weather";
    extraGroups = [ "wheel" ];
  };

  preDNS.enable = false;
  users.users.root = userBase;

  #environment.systemPackages = with pkgs; [
  #];

  system.stateVersion = "21.11";
}
