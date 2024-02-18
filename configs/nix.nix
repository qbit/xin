{ pkgs, ... }:
{
  nix = {
    package = pkgs.nixVersions.nix_2_19;
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 10d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.auto-optimise-store = true;
    settings = {
      sandbox = true;
      trusted-users = [ "@wheel" ];
      allowed-users = [
        "root"
        "qbit"
      ];
    };
  };
}
