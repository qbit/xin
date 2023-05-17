{ tea, gh, _1password, hut }:

let
  teaBin = "${tea}/bin/tea";
  ghBin = "${gh}/bin/gh";
  htBin = "${hut}/bin/hut";

in ''
  #!/usr/bin/env sh

  set -eu

  source ~/.config/op/plugins.sh

  proj="$(basename $PWD)"

  for login in $(${teaBin} logins list -o simple | awk '{print $1}'); do
    tea logins default "$login"
    tea repos create -name "$proj" || echo "error creating '$proj' on '$login'"
  done

  # ${ghBin}
  gh repo create --public "$proj" || echo "error creating '$proj' on 'github'"

  # ${htBin}
  ${htBin} git create "$proj" || echo "error creating '$proj' on 'sr.ht'"

''
