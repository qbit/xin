{ pkgs, ... }:
let
  nixOptions = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 10d";
    };

    # Enable flakes
    package = pkgs.nixVersions.nix_2_17;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
in
{ nix = { settings.auto-optimise-store = true; } // nixOptions; }
