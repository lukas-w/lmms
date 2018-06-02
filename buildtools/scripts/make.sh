#!/usr/bin/env bash
export SCRIPT="$0"
export DIR=$(dirname "$0")
source "$DIR/detail/common-build.sh"
set -e

TARGET=$1

SYSTEM=$(uname -s)
if [[ "$SYSTEM" == "Linux" ]]; then
	MAKEFLAGS=-j$(nproc)
elif [[ "$SYSTEM" == "Darwin" ]]; then
	MAKEFLAGS=-j$(sysctl -n hw.physicalcpu)
fi

if [ -z $TARGET ]; then
	cmake --build "$BUILD_DIR" -- $MAKEFLAGS
	cmake --build "$BUILD_DIR" --target tests -- $MAKEFLAGS
else
	cmake --build "$BUILD_DIR" --target $TARGET -- $MAKEFLAGS
fi
