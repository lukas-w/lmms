#!/usr/bin/env bash
set -e
export SCRIPT="$0"
export DIR=$(dirname "$0")
source "$DIR/../scripts/detail/common.sh"

CONTAINER_NAME=$1
COMMAND=${@:2}

PIPE="docker exec --interactive $CONTAINER_NAME /bin/bash -"

while ! echo "$COMMAND" | $PIPE; do
	error -n "Running command $COMMAND failed. "

	if ! [[ $- == *i* || "$PS1" ]]; then
		# Non-interactive shell. Exit
		exit 1
	fi

	if confirm "Do you want me to drop you into a shell to fix it? [Y/n]" y; then
		docker exec -it $CONTAINER_NAME /bin/bash
	else
		exit 1
	fi
done
