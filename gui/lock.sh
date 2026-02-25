#!/bin/sh

if [ -z "$SSH_AUTH_SOCK" ]; then
	SSH_AUTH_SOCK=/run/user/1000/ssh-agent
fi

ssh-add -D || echo "can't remove ssh keys"
sudo -K || echo "can't remove sudo cookie"
wl-copy --clear || echo "can't clearn clipboard"
wl-copy --primary --clear || echo "can't clear primary clipboard"

case "$1" in
lidshut)
	swaylock -f -c 000000
	systemctl suspend-then-hibernate
	;;
lock)
	swaylock -f -c 000000
	;;
suspend)
	brightnessctl --save
	brightnessctl set 0
	if on_ac_power; then
		echo "on power, not suspending"
	else
		systemctl suspend-then-hibernate
	fi
	;;
resume)
	brightnessctl --restore
	;;
*)
	echo "unknown command"
	;;
esac
