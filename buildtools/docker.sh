#!/usr/bin/env bash
set -e
export SCRIPT="$0"
DIR=$(dirname "$0")
# shellcheck source=buildtools/scripts/detail/common.sh
source "$DIR/scripts/detail/common.sh"

IMAGE_NAME=$1
TAG=$2
IMAGE=lmmsci/$1:$2

"$DIR/docker/build-image.sh" "$IMAGE_NAME" "$TAG"

CONTAINER_NAME="lmms-build-$IMAGE_NAME-$TAG"

info "Cleaning up old container"
	docker stop "$CONTAINER_NAME" >/dev/null || true
	docker rm "$CONTAINER_NAME" >/dev/null || true

function run() {
	info Running $@
	"$DIR/docker/run.sh" "$CONTAINER_NAME" "$@"
}

function cleanup() {
	info "Cleaning up"
	"$DIR/docker/stop.sh" "$CONTAINER_NAME" > /dev/null
}

"$DIR/docker/start.sh" "$IMAGE" "$CONTAINER_NAME" "$3"
trap cleanup EXIT

if [[ "$IMAGE_NAME" == ubuntu-linux-* ||
	 "$IMAGE_NAME" == ubuntu-mingw-* ]]; then
	prefix="ubuntu-"
	target=${IMAGE_NAME:${#prefix}}
	info "Configuring"
	run CMAKE_FLAGS=\"-DUSE_CCACHE=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DUSE_WERROR=ON\" /src/buildtools/scripts/configure.sh "$target"
	info "Compiling"
	run /src/buildtools/scripts/make.sh
	if [[ $IMAGE_NAME != ubuntu-mingw-* ]]; then
		../buildtools/docker/run.sh "$CONTAINER_NAME" /src/buildtools/scripts/make.sh tests
		../buildtools/docker/run.sh "$CONTAINER_NAME" /build/tests/tests
	fi
	if [[ $IMAGE_NAME == ubuntu-linux-* || $TAG == "14.04" ]]; then
		info "Packaging"
		run /src/buildtools/scripts/package.sh "$target"
	fi
fi
