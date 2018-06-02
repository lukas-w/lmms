#!/usr/bin/env bash
export SCRIPT="$0"
DIR=$(dirname "$0")
# shellcheck source=buildtools/scripts/detail/common-build.sh
source "$DIR/detail/common-build.sh"
set -e

SYSTEM=$(uname -s)

if [[ "$SYSTEM" == "Linux" ]]; then
	DISTRO=$(lsb_release -is)
	DISTRO_VER=$(lsb_release -rs)

	TARGET=$1

	if [[ "$DISTRO" == "Ubuntu" && "$DISTRO_VER" == "14.04" ]]; then
		if [[ "$TARGET" == "mingw-w32" ]]; then
			TOOLCHAIN="Ubuntu-MinGW-X-Trusty-32.cmake"
		elif [[ "$TARGET" == "mingw-w64" ]]; then
			TOOLCHAIN="Ubuntu-MinGW-X-Trusty-64.cmake"
		else
			unset QTDIR QT_PLUGIN_PATH LD_LIBRARY_PATH
			# shellcheck disable=SC1091
			source /opt/qt59/bin/qt59-env.sh || true
		fi
	else
		if [[ "$TARGET" == "mingw-w32" ]]; then
			TOOLCHAIN="Ubuntu-MinGW-W64-32.cmake"
		elif [[ "$TARGET" == "mingw-w64" ]]; then
			TOOLCHAIN="Ubuntu-MinGW-W64-64.cmake"
		fi
	fi
elif [[ "$SYSTEM" == "Darwin" ]]; then
	# Workaround; No FindQt5.cmake module exists
	CMAKE_PREFIX_PATH="$(brew --prefix qt5)"
	export CMAKE_PREFIX_PATH
fi

if [[ "$TOOLCHAIN" ]]; then
	TOOLCHAIN="$SOURCE_DIR/cmake/toolchains/$TOOLCHAIN"
	CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN"
fi

info "Configuring in build directory $BUILD_DIR"

mkdir -p "$BUILD_DIR"
pushd "$BUILD_DIR" > /dev/null
pwd
cmake $CMAKE_FLAGS -DCMAKE_INSTALL_PREFIX=../target $@ "$SOURCE_DIR"
popd  > /dev/null
