{ ... }:
{
  environment.systemPackages = [
    #(callPackage ./cinny-desktop.nix { inherit isUnstable; })
    #(callPackage ./mudita-center.nix { inherit isUnstable; })
    #(callPackage ./govulncheck.nix { inherit isUnstable; })
  ];
}
