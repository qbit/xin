#!@shell@ -e

BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# TODO: Use the following for more accurate, to-the-input results:
# nix flake metadata --json | jq -r '.locks.nodes[] | select(.original.repo == "nixpkgs" and .original.owner == "NixOS") | [ .original.ref, .locked.lastModified ] | join("^")'

FLAKE_EPOCH=$(@nix@/bin/nix flake metadata --json | @jq@/bin/jq .lastModified)
NOW_EPOCH=$(@coreutils@/bin/date +"%s")

EPOCH_DIFF=$((NOW_EPOCH - FLAKE_EPOCH))

if [ $EPOCH_DIFF -gt $((60480 * 5)) ]; then
	echo
	echo "${BOLD}WARNING: inputs haven't been updated in $((EPOCH_DIFF / 86400)) days!${NORMAL}"
	echo
fi
