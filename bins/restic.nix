{ pkgs }:

let resticBin = "${pkgs.restic}/bin/restic";
in ''
  #!/usr/bin/env sh

  export $(cat /run/secrets/restic_env_file)
  ${resticBin} --password-file /run/secrets/restic_password_file $@
''
