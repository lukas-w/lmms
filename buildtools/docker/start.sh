#!/usr/bin/env bash
set -e
export SCRIPT="$0"
export DIR=$(dirname "$0")
source "$DIR/../scripts/detail/common.sh"

IMAGE=$1
CONTAINER_NAME=$2
BUILD_DIR=$3

if [ "$BUILD_DIR" ]; then
	BUILD_DIR=$(readlink -f "$3")
	DOCKER_ARGS="$DOCKER_ARGS -v $BUILD_DIR:/build"
fi

SOURCE_DIR=$(realpath "$DIR/../../")

info "Starting container"

docker run --name $CONTAINER_NAME -t -d  \
	-v "$SOURCE_DIR":/src  \
	-v $HOME/.ccache:/root/.ccache       \
	-e SOURCE_DIR=/src                   \
	-e BUILD_DIR=/build                  \
	$DOCKER_ARGS $IMAGE

info "Started container as $CONTAINER_NAME"
