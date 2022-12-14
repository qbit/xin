{ config, lib, pkgs, isUnstable, ... }:

with lib;

let
  userBase = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = config.myconf.hwPubKeys
      ++ config.myconf.managementPubKeys;
  };
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

    programs.ssh = {
      startAgent = true;
      agentTimeout = "100m";
      extraConfig = ''
        VerifyHostKeyDNS	yes
        AddKeysToAgent		confirm 90m
        CanonicalizeHostname	always

        Host *
          controlmaster         auto
          controlpath           /tmp/ssh-%r@%h:%p
      '';
    };

    environment.systemPackages =
      if isUnstable then [ pkgs.yash pkgs.go ] else [ pkgs.go ];
  };
}
