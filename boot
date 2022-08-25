#!/usr/bin/env sh


case $1 in
	weather)
		nix build .#nixosConfigurations.weatherInstall.config.system.build.sdImage
		;;
	haas)
		nix build .#nixosConfigurations.hassInstall.config.system.build.isoImage
		;;
	*)
		echo "Usage: boot [weather|hass]"
esac
