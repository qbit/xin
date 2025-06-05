{
  curl,
  gosignify,
}:
''
  #!/usr/bin/env sh

  set -e

  SERVER=cdn.openbsd.org
  ITEM=$1
  MACHINE=''${2:-amd64}
  V="$(echo $ITEM | sed 's/[^0-9]*//g')"
  [[ ! -z $2 ]] && MACHINE=$2
  ${curl}/bin/curl -s -o "$PWD/$ITEM" "https://$SERVER/pub/OpenBSD/snapshots/$MACHINE/$ITEM" && \
  ${curl}/bin/curl -s -o "$PWD/SHA256.sig" "https://$SERVER/pub/OpenBSD/snapshots/$MACHINE/SHA256.sig"

  ${gosignify}/bin/gosignify -C -p "/etc/signify/openbsd-$V-base.pub" -x SHA256.sig "$ITEM"

''
