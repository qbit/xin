{ config, lib, pkgs, isUnstable, ... }:

with lib;

let
  userBase = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = config.myconf.hwPubKeys;
  };
  goVersion = pkgs.go_1_18;
in {
  options = {
    defaultUsers = {
      enable = mkOption {
        description = "Enable regular set of users";
        default = true;
        example = true;
        type = lib.types.bool;
      };
    };
  };

  config = mkIf config.defaultUsers.enable {
    users.users.root = userBase;
    users.users.qbit = userBase // {
      isNormalUser = true;
      description = "Aaron Bieber";
      home = "/home/qbit";
      extraGroups = [ "wheel" ];
    };

    environment.systemPackages =
      if isUnstable then [ goVersion pkgs.yash ] else [ goVersion ];

    programs.ssh = {
      startAgent = true;
      agentTimeout = "100m";
      extraConfig = ''
        VerifyHostKeyDNS	yes
        AddKeysToAgent		confirm 90m
        CanonicalizeHostname	always

        Host *
          controlmaster auto
          controlpath /tmp/ssh-%r@%h:%p

        Include /home/qbit/.ssh/host_config
      '';
    };
  };
}
