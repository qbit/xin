{ tea, gh, _1password }:

let
  teaBin = "${tea}/bin/tea";
  ghBin = "${gh}/bin/gh";
  opBin = "${_1password}/bin/op";

in ''
  #!/usr/bin/env sh

  set -eu

  proj="$(basename $PWD)"

  for login in $(${teaBin} logins list -o simple | awk '{print $1}'); do
    tea logins default "$login"
    tea repos create -name "$proj" || echo "error creating '$proj' on '$login'"
  done

  # ${ghBin}
  ${opBin} plugin run -- gh repo create --public "$proj" || echo "error creating '$proj' on 'github'"

''
