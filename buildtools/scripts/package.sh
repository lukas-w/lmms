#!/usr/bin/env bash
export SCRIPT="$0"
export DIR=$(dirname "$0")
source "$DIR/detail/common-build.sh"
set -e

SYSTEM=$(uname -s)
SYSTEM_TARGET=$1

if [[ "$SYSTEM" == "Linux" ]]; then
	if [[ "$SYSTEM_TARGET" == mingw-* ]]; then
		"$DIR/make.sh" package
	else
		"$DIR/make.sh" install > /dev/null
		"$DIR/make.sh" appimage
	fi
elif [[ "$SYSTEM" == "Darwin" ]]; then
	"$DIR/make.sh" install > /dev/null
	"$DIR/make.sh" dmg
fi
