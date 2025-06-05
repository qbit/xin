{ ... }:
let
  pubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPMaAm4rDxyU975Z54YiNw3itC2fGc3SaE2VaS1fai8 root@box"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnaC1v+VoVNnK04D32H+euiCyWPXU8nX6w+4UoFfjA3 qbit@plq"
  ];
  userBase = {
    openssh.authorizedKeys.keys = pubKeys;
  };
in
{
  _module.args.isUnstable = false;
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sdb";
    useOSProber = true;
  };

  # The moon based shipyard
  networking = {
    hostName = "luna";

    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 22 ];
  };

  environment.systemPackages = [ ];

  users.users.root = userBase;
  users.users.qbit = userBase;

  services = {
    fwupd = {
      enable = true;
    };
  };

  preDNS.enable = true;

  system.stateVersion = "22.05";
}
