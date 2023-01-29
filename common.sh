. /etc/profile
. /run/secrets/po_env

NIX_SSHOPTS="-i /run/secrets/manager_pubkey -oIdentitiesOnly=yes -oControlPath=/tmp/manager-ssh-%r@%h:%p -F/dev/null"
SSH="ssh ${NIX_SSHOPTS}"
CurrentVersion="$(git rev-parse HEAD)"
AgentKeys="$(ssh-add -L | awk '{print $2}')"
RunHost="$(uname -n)"

msg() {
	echo -e "===> $@"
}

listNixOSHosts() {
	for i in $(nix eval .#nixosConfigurations --apply builtins.attrNames --json | jq -r '.[]'); do
		if [ -d hosts/${i} ]; then
			echo $i
		fi
	done
}

resolveAlias() {
	host="${1}"
	if [ -f hosts/${host}/alias ]; then
		cat "hosts/${host}/alias"
		return
	fi
	echo "$host"
}

agentHasKey() {
	checkKey="$(echo $1 | awk '{print $NF}')"
	for i in $AgentKeys; do
		if [[ "$i" == $checkKey ]]; then
			return 0
		fi
	done
	return 1
}

isRunHost() {
	if [ "$1" = "$RunHost" ]; then
		return 0
	fi
	return 1
}

tsAlive() {
	ping -c 1 -w 2 $1 >/dev/null 2>&1 && return 0
	tailscale ping --timeout 2s --c 1 --until-direct=false $1 >/dev/null 2>&1 && return 0
	return 1
}

error() {
	msg "Something went wrong!"
	exit 1
}

ci_error() {
	git reset --hard HEAD
	git clean -fd
	git checkout main
}

po_error() {
	po -title "$1" -body "$2"
	ci_error
}

start() {
	agentHasKey "$(cat /run/secrets/manager_pubkey | awk '{print $2}')" ||
		ssh-add /run/secrets/manager_key
}

finish() {
	ssh-add -d /run/secrets/manager_key
	exit 0
}

handle_co_fail() {
	po_error "CI: git checkout failed!" "Pelase help!"
}

handle_update_fail() {
	po_error "CI: flake input update failed!" "Pelase help!"
}

handle_check_fail() {
	po_error "CI: flake checks failed!" "Pelase help!"
}
