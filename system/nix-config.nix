{ pkgs, xinlib, ... }:
let
  inherit (xinlib) todo;
  nixOptions = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 10d";
    };

    # Enable flakes
    package = todo "nix 2.18 has a regress: https://github.com/NixOS/nix/issues/9052" pkgs.nixVersions.nix_2_17;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
in
{ nix = { settings.auto-optimise-store = true; } // nixOptions; }
