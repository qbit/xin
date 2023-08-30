{
  callPackage,
  lib,
  fetchFromGitHub,
}: let
  inherit (builtins) readFile fromJSON;
  common = opts: callPackage (import ./common.nix opts) {};
  verStr = fromJSON (readFile ./version.json);
in {
  openssh = common {
    pname = "openssh";
    inherit (verStr) version;

    src = fetchFromGitHub {
      inherit (verStr) rev hash;
      owner = "openssh";
      repo = "openssh-portable";
    };

    extraPatches = [./ssh-keysign-8.5.patch];
    extraMeta.maintainers = with lib.maintainers; [qbit];
  };
}