#!@shell@ -e

BOLD=$(tput bold)
NORMAL=$(tput sgr0)

FLAKE_EPOCH=$(@nix@/bin/nix flake metadata --json | @jq@/bin/jq .lastModified)
NOW_EPOCH=$(@coreutils@/bin/date +"%s")

EPOCH_DIFF=$(($NOW_EPOCH - $FLAKE_EPOCH))

if [ $EPOCH_DIFF -gt 60480 ]; then
	echo "${BOLD}WARNING: inputs haven't been updated in $(($EPOCH_DIFF / 86400)) days!${NORMAL}"
fi
