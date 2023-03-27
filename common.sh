. /etc/profile
. /run/secrets/po_env

SCRIPT_NAME="${0##*/}"
SCRIPT_PID=$$
LOCK_PATH="${LOCK:-/tmp/xin}"
LOCK_FILE="${LOCK_PATH}/${SCRIPT_NAME}"

mkdir -p "${LOCK_PATH}"

NIX_SSHOPTS="-i /run/secrets/manager_pubkey -oIdentitiesOnly=yes -oControlPath=/tmp/manager-ssh-%r@%h:%p -F/dev/null"
SSH="ssh ${NIX_SSHOPTS}"
CurrentVersion="$(git rev-parse HEAD)"
AgentKeys="$(ssh-add -L | awk '{print $2}')"
RunHost="$(uname -n)"

msg() {
	echo -e "===> $@"
}

unlock() {
	rm -f ${LOCK_FILE}
}

_lock() {
	echo "${SCRIPT_PID}" >"${LOCK_FILE}"
	trap 'unlock' INT EXIT TERM
}

lock() {
	if [ -f "${LOCK_FILE}" ]; then
		msg "${SCRIPT_NAME} already running..."
		exit 0
	else
		_lock
	fi
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

start_ci() {
	lock
	agentHasKey "$(cat /run/secrets/ci_ed25519_pub | awk '{print $2}')" ||
		ssh-add /run/secrets/ci_ed25519_key
}

finish() {
	ssh-add -d /run/secrets/manager_key
	ssh-add -d /run/secrets/ci_ed25519_key
	exit 0
}

handle_pull_fail() {
	po_error "CI: git pull failed!" "Pelase help!"
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

handle_update_check_fail() {
	po_error "CI: flake checks failed while updating!" "Pelase help!"
}

handle_merge_fail() {
	po_error "CI: git merge failed!" "Pelase help!"
}

handle_push_fail() {
	po_error "CI: git push failed!" "Pelase help!"
}
