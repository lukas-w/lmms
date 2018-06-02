set -e

SCRIPTNAME=$(basename "$SCRIPT")

function _log {
	cls="$1"
	color="$2"

	msg="${@:3}"
	if [[ $3 == "-n" ]]; then
		arg="-n"
		msg="${@:4}"
	fi

	echo $arg -e "${color}[$SCRIPTNAME][${cls}]\e[39m ${msg}"
}

function info() {
	_log info "\e[35m" "${@:1}"
}
function error() {
	_log error "\e[31m" "${@:1}"
}
function fatal() {
	error $@
	exit 1
}

function confirm() {
	while true; do
		read -p "$1 " yn
		case ${yn:-$2} in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo -n "Please answer yes or no. ";;
		esac
	done
}

error_exit() {
	local parent_lineno="$1"
	local message="$2"
	local code="${3:-1}"
	if [[ -n "$message" ]] ; then
		error "Error near line ${parent_lineno}: ${message}; exiting with status ${code}"
	else
		error "Error near line ${parent_lineno}; exiting with status ${code}"
	fi
	exit "${code}"
}
trap 'error_exit $(basename ${BASH_SOURCE}):${LINENO}' ERR

function docker {
	sudo docker $@
}

# For macOS
if ! [ -x "$(command -v realpath)" ]; then
	realpath() {
		[[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
	}
fi
