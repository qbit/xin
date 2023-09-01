{
  lib,
  writeTextFile,
  linkFarm,
  ...
}: let
  inherit
    (builtins)
    toString
    readFile
    fromJSON
    filter
    concatStringsSep
    map
    ;
  makeListReFile = name: list:
    writeTextFile {
      inherit name;
      text = concatStringsSep "\n" (map (h: ".*(^|\\.)${h}$") list);
    };
  getPrStatus = pr: let
    prstr = toString pr;
    prStatus = fromJSON (readFile ../pull_requests/${prstr}.json);
  in
    prStatus;
  prIsOpen = {
    pkg = pr: localPkg: upstreamPkg: let
      prStatus = getPrStatus pr;
    in
      if prStatus.status == "open"
      then localPkg
      else
        lib.warn
        "PR: ${toString pr} (${prStatus.title}) is complete, ignoring pkg..."
        upstreamPkg;

    overlay = pr: overlay: let
      prStatus = getPrStatus pr;
    in
      if pr == 0 || prStatus.status == "open"
      then overlay
      else
        lib.warn "PR: ${
          toString pr
        } (${prStatus.title}) is complete, ignoring overlay..." (_: _: {});
  };

  osRuleMaker = {
    allowBinAll = name: bin: {
      name = "${name}";
      enabled = true;
      precidence = false;
      action = "allow";
      duration = "always";
      operator = {
        type = "simple";
        sensitive = false;
        operand = "process.path";
        data = "${bin}";
      };
    };
    makeBinList = name: action: bin: list: {
      inherit action name;
      enabled = true;
      precidence = true;
      duration = "always";
      operator = {
        type = "lists";
        operand = "lists";
        sensitive = false;
        list = [{} {}];
      };
    };
    makeREList = name: action: list: {
      inherit action name;
      enabled = true;
      precidence = true;
      duration = "always";
      operator = {
        type = "lists";
        operand = "lists.domains_regexp";
        sensitive = false;
        data = linkFarm "${name}-${action}-dir" [
          {
            name = "${name}-${action}-file";
            path = makeListReFile "${name}-${action}-list" list;
          }
        ];
        list = [];
      };
    };
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
      serviceConfig = {Type = "oneshot";};
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
  buildVer = self: let
    state = self.rev or "DIRTY";
  in {
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
      osRuleMaker
      ;
  };
in
  xinlib
