#!/bin/sh

if [ -z "$SSH_AUTH_SOCK" ]; then
	SSH_AUTH_SOCK=/run/user/1000/ssh-agent
fi

ssh-add -D
sudo -K

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
