{
  callPackage,
  lib,
  fetchFromGitHub,
}: let
  common = opts: callPackage (import ./common.nix opts) {};
in {
  openssh = common {
    pname = "openssh";
    version = "unstable-2023-08-29";

    src = fetchFromGitHub {
      owner = "openssh";
      repo = "openssh-portable";
      rev = "f98031773db361424d59e3301aa92aacf423d920";
      hash = "sha256-MxEwe4x/PIjofzGzQC4LhladRQT5AcnDa+BwMm0DQx4=";
    };

    extraPatches = [./ssh-keysign-8.5.patch];
    extraMeta.maintainers = with lib.maintainers; [qbit];
  };
}
