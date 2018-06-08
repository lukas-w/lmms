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
	if ! [ "$CIRCLECI" ]; then
		DOCKER_ARGS="$DOCKER_ARGS -v $BUILD_DIR:/build"
	fi
fi

SOURCE_DIR=$(realpath "$DIR/../../")

info "Starting container"

if ! [ "$CIRCLECI" ]; then
	DOCKER_ARGS="$DOCKER_ARGS -v $SOURCE_DIR:/src"
	DOCKER_ARGS="$DOCKER_ARGS -v $HOME/.ccache:/root/.ccache"
fi

docker run --name $CONTAINER_NAME -t -d  \
	-e SOURCE_DIR=/src                   \
	-e BUILD_DIR=/build                  \
	$DOCKER_ARGS $IMAGE

if [ "$CIRCLECI" ]; then
	docker cp $SOURCE_DIR $CONTAINER_NAME:/src
fi

info "Started container as $CONTAINER_NAME"
