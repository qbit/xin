{ tea
, gh
, hut
,
}:
let
  teaBin = "${tea}/bin/tea";
  ghBin = "${gh}/bin/gh";
  htBin = "${hut}/bin/hut";
in
''
  #!/usr/bin/env sh

  set -eu

  source ~/.config/op/plugins.sh

  proj="$(basename $PWD)"

  for login in $(${teaBin} logins list -o simple | awk '{print $1}'); do
    tea logins default "$login"
    tea repos create --private --name "$proj" || echo "error creating '$proj' on '$login'"
  done

  # ${ghBin}
  gh repo create --public "$proj" || echo "error creating '$proj' on 'github'"

  # ${htBin}
  ${htBin} git create "$proj" || echo "error creating '$proj' on 'sr.ht'"

  git config --unset-all remote.origin.url || echo "no remote defined..."
  for repo in "git@github.com:qbit/%s.git" "git@gitle.otter-alligator.ts.net:%s" "ssh://gitea@git.tapenet.org:2222/qbit/%s.git" "git@codeberg.org:qbit/%s.git" "git@git.sr.ht:~qbit/%s"; do
    echo "Adding remote: $(printf $repo $proj)"
    git config --add remote.origin.url "$(printf $repo $proj)"
  done

''
