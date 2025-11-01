{
  ...
}:
{
  nixpkgs.overlays = [
    (_: super: {
      smug = super.smug.overrideAttrs (_: rec {
        version = "0.3.3";

        src = super.fetchFromGitHub {
          owner = "ivaaaan";
          repo = "smug";
          rev = "v${version}";
          sha256 = "sha256-dQp9Ov8Si9DfziVtX3dXsJg+BNKYOoL9/WwdalQ5TVw=";
        };

        vendorHash = "sha256-vaDUzVRmpmNn8/vUPeR1U5N6T4llFRIk9A1lum8uauU=";
      });
    })
  ];
}
