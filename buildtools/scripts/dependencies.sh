#!/usr/bin/env bash
export SCRIPT="$0"
export DIR=$(dirname "$0")
source "$DIR/detail/common.sh"
set -e

SYSTEM=$(uname -s)

if [[ "$SYSTEM" == "Linux" ]]; then
	DISTRO=$(lsb_release -is)
	DISTRO_VER=$(lsb_release -rs)

	$DIR/detail/packages.sh $DISTRO $DISTRO_VER
else
	fatal "Your operating system is not supported"
fi
