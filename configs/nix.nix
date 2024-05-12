{ pkgs, inputs, lib, ... }:
{
  nix =
    let myPkgs = inputs.unstableSmall.legacyPackages.${pkgs.system};
    in {
      package = if lib.hasAttr "lix" myPkgs then myPkgs.lix else myPkgs.nixVersions.nix_2_21;
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
        allowed-users = [ "root" "qbit" ];
      };
    };
}
