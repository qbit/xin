{ minisign, curl }:

''
    #!/usr/bin/env sh

    set -e

    SERVER=cdn.openbsd.org
    ITEM=$1
    MACHINE=amd64
    VER=snapshots
    V=7.1
    [[ ! -z $2 ]] && MACHINE=$2
    if [[ ! -z $3 ]]; then
  	VER=$3
  	V=$(echo $VER | sed 's/\.//')
    fi
    ${curl}/bin/curl -o "$PWD/$ITEM" "https://$SERVER/pub/OpenBSD/$VER/$MACHINE/$ITEM" && \
    ${curl}/bin/curl -o "$PWD/SHA256.sig" "https://$SERVER/pub/OpenBSD/$VER/$MACHINE/SHA256.sig"

    ${minisign}/bin/minisign -C -p "/etc/signify/openbsd-$V-base.pub" -x SHA256.sig "$ITEM"

''
