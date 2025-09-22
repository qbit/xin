. /etc/profile

if [[ -f /run/secrets/po_env ]]; then
	. /run/secrets/po_env
fi

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
		if [[ $i == $checkKey ]]; then
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
	ping -4 -c 1 -w 2 $1 >/dev/null 2>&1 && return 0
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

_po() {
	po -title "$1" -body "$2"
}

po_error() {
	po -title "$1" -body "$2"
	ci_error
}

start() {
	agentHasKey "$(cat /run/secrets/manager_pubkey | awk '{print $2}')" ||
		ssh-add -t 500 /run/secrets/manager_key
}

start_ci() {
	lock
	agentHasKey "$(cat /run/secrets/ci_ed25519_pub | awk '{print $2}')" ||
		ssh-add /run/secrets/ci_ed25519_key
	agentHasKey "$(cat /run/secrets/ci_signing_ed25519_pub | awk '{print $2}')" ||
		ssh-add /run/secrets/ci_signing_ed25519_key
}

finish() {
	ssh-add -d /run/secrets/manager_key
	exit 0
}

finish_ci() {
	ssh-add -d /run/secrets/ci_ed25519_key
	ssh-add -d /run/secrets/ci_signing_ed25519_key
	pkill ssh-agent # TODO: https://github.com/systemd/systemd/pull/28035
	exit 0
}

get_journal() {
	journalctl -u "$1" -n 50 --no-pager
}

handle_pull_fail() {
	po_error "CI: git pull failed!" "$(get_journal xin-ci-update)"
}

handle_co_fail() {
	_po "CI: git checkout ($1) failed!" "Please help!"
}

handle_update_fail() {
	_po "CI: input '$1' update failed!" "$(get_journal xin-ci-update)"
}

handle_check_fail() {
	po_error "CI: checks failed!" "$(get_journal xin-ci)"
}

handle_update_check_fail() {
	_po "CI: checks for $1 failed!" "$(get_journal xin-ci-update)"
}

handle_merge_fail() {
	_po "CI: git merge ('$1' into '$2') failed!" "$(get_journal xin-ci-update)"
}

handle_push_fail() {
	po_error "CI: git push failed!" "$(get_journal xin-ci-update)"
}
