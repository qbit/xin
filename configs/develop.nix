{ config, lib, pkgs, ... }:
with lib; {
  options = {
    jetbrains = { enable = mkEnableOption "Install JetBrains editors"; };
  };

  config = mkMerge [
    (mkIf config.jetbrains.enable {
      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [ "idea-ultimate" ];

      environment.systemPackages = with pkgs; [ jetbrains.idea-ultimate sshfs ];
    })
  ];
}
