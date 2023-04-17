{ lib, pkgs, config, ... }:

assert (builtins.length
  (lib.mapAttrsToList (a: _: a) config.services.restic.backups)) <= 1;

let
  resticBin = "${pkgs.restic}/bin/restic";
  cfg = config.services.restic.backups;
  bkp = lib.mapAttrs' (_: lib.nameValuePair "default") cfg;
in ''
  #!/usr/bin/env sh

  set -e

  export $(cat ${bkp.default.environmentFile})
  ${resticBin} -r ${bkp.default.repository} --password-file ${bkp.default.passwordFile} $@
''
