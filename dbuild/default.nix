{ config, lib, ... }:
with lib; {
  imports = [ ./build-consumer.nix ./build-server.nix ];
}
