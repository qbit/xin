{ lib, ... }:
let
  mkCronScript = name: src: ''
    . /etc/profile;
    set -x
    # autogenreated ${name}
    ${src}
  '';
  jobToUserService = job: {
    name = "${job.name}";
    value = {
      script = mkCronScript "${job.name}_script" job.script;
      inherit (job) startAt path;
    };
  };
  jobToService = job: {
    name = "${job.name}";
    value = {
      script = mkCronScript "${job.name}_script" job.script;
      inherit (job) startAt path;
      serviceConfig = { User = "${job.user}"; };
    };
  };
  buildShell = pkgs:
    pkgs.mkShell {
      shellHook = ''
        PS1='\u@\h:\w; '
        ( . ./common.sh; start ) || true;
      '';
      nativeBuildInputs = with pkgs; [
        deadnix
        git
        git-bug
        jq
        nil
        nix-diff
        nix-output-monitor
        shfmt
        sops
        ssh-to-age
        ssh-to-pgp
        statix
      ];
    };

  # Set our configurationRevison based on the status of our git repo.
  # If the repo is dirty, disable autoUpgrade as it means we are
  # testing something.
  buildVer = self:
    let state = self.rev or "DIRTY";
    in {
      system.configurationRevision = state;
      system.autoUpgrade.enable = lib.mkDefault (state != "DIRTY");
    };

  xinlib = {
    inherit buildVer mkCronScript jobToUserService jobToService buildShell;
  };

in xinlib
