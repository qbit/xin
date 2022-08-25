{ config, lib, ... }:

with lib; {
  options = {
    buildServer = {
      enable = mkEnableOption "Server will be used as part of the build infra";
    };
  };

  config = mkIf config.buildServer.enable {
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICEtoU6ObMP7wmglT7rXMg0HEnh7cGBo6COL7BpmRC/o"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyOQdqfm7mG+5rOGIqPHSaZQdG/4L03dVJnuE1lO1fo"
    ];
  };
}
