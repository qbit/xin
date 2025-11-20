{ lib, ... }:
let
  inherit (builtins)
    toString
    readFile
    fromJSON
    filter
    ;
  getPrStatus =
    pr:
    let
      prstr = toString pr;
      prStatus = fromJSON (readFile ../pull_requests/${prstr}.json);
    in
    prStatus;
  prIsOpen = {
    str =
      pr: a:
      let
        prStatus = getPrStatus pr;
      in
      if prStatus.status == "open" then
        lib.warn "PR: ${toString pr} (${prStatus.title}) is open.. disabling option" null
      else
        a;
    option =
      pr: a:
      let
        prStatus = getPrStatus pr;
      in
      if prStatus.status == "open" then a else { };
    list =
      pr: a:
      let
        prStatus = getPrStatus pr;
      in
      if prStatus.status == "open" then a else [ ];

    pkg =
      pr: localPkg: upstreamPkg:
      let
        prStatus = getPrStatus pr;
      in
      if prStatus.status == "open" then
        localPkg
      else
        lib.warn "PR: ${toString pr} (${prStatus.title}) is complete, ignoring pkg..." upstreamPkg;

    overlay =
      pr: overlay:
      let
        prStatus = getPrStatus pr;
      in
      if pr == 0 || prStatus.status == "open" then
        overlay
      else
        lib.warn "PR: ${toString pr} (${prStatus.title}) is complete, ignoring overlay..." (_: _: { });
  };

  todo = msg: lib.warn "TODO: ${msg}";

  filterList = pkgList: filter (x: x != null) pkgList;

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
      serviceConfig = {
        Type = "oneshot";
      };
    };
  };
  jobToService = job: {
    name = "${job.name}";
    value = {
      script = mkCronScript "${job.name}_script" job.script;
      inherit (job) startAt path;
      serviceConfig = {
        User = "${job.user}";
        Type = "oneshot";
      };
    };
  };
  buildShell =
    pkgs:
    pkgs.mkShell {
      shellHook = ''
        PS1='\u@\h:\w; '
      '';
      nativeBuildInputs = with pkgs; [
        curl
        dasel
        deadnix
        direnv
        git
        git-bug
        jo
        jq
        lixPackageSets.stable.lix
        nil
        nix-diff
        nix-output-monitor
        nix-prefetch-github
        shfmt
        sops
        ssh-to-age
        ssh-to-pgp
        statix
        treefmt
        perlPackages.PerlTidy
      ];
    };

  # Set our configurationRevison based on the status of our git repo.
  # If the repo is dirty, disable autoUpgrade as it means we are
  # testing something.
  buildVer =
    self:
    let
      state = self.rev or "DIRTY";
    in
    {
      system.configurationRevision = state;
      system.autoUpgrade.enable = lib.mkDefault (state != "DIRTY");
    };

  xinlib = {
    inherit
      buildVer
      mkCronScript
      jobToUserService
      jobToService
      buildShell
      prIsOpen
      filterList
      todo
      ;
  };
in
xinlib
