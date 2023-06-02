{ lib, ... }:
# TODO: this could be cleaner :D
let
  getPrStatus = pr:
    let
      prstr = builtins.toString pr;
      prStatus =
        builtins.fromJSON (builtins.readFile ../pull_requests/${prstr}.json);
    in prStatus;
  prIsOpen = {
    pkg = pr: pkg:
      let prStatus = getPrStatus pr;
      in if prStatus.status == "open" then
        pkg
      else
        lib.warn "PR: ${
          builtins.toString pr
        } (${prStatus.title}) is complete, ignoring pkg..." null;

    overlay = pr: overlay:
      let prStatus = getPrStatus pr;
      in if prStatus.status == "open" then
        overlay
      else
        lib.warn "PR: ${
          builtins.toString pr
        } (${prStatus.title}) is complete, ignoring overlay..." (_: _: { });
  };

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
        curl
        deadnix
        git
        git-bug
        jo
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
    inherit buildVer mkCronScript jobToUserService jobToService buildShell
      prIsOpen;
  };

in xinlib
