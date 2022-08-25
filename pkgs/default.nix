{ config, lib, pkgs, isUnstable, ... }:

with pkgs; {
  environment.systemPackages = with pkgs; [
    (callPackage ./cinny-desktop.nix { inherit isUnstable; })
    (callPackage ./mudita-center.nix { inherit isUnstable; })
  ];
}
