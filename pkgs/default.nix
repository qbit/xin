{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.callPackage ./hister.nix { })
  ];
}
