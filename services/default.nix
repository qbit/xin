{ config, lib, pkgs, ... }:
with lib; {
  imports = [ ./ssh-fido-agent.nix ./config-manager.nix ];
}
