#!/usr/bin/env bash
set -e

CMAKE_FLAGS="$CMAKE_FLAGS -DUSE_WERROR=ON"
export CMAKE_FLAGS

# Start the docker container
IMAGE=ci-image
CONTAINER_NAME=TRAVIS
BUILD_DIR=$(pwd)/build
buildtools/docker/start.sh "$IMAGE" "$CONTAINER_NAME" "$BUILD_DIR"

PREFIX="ubuntu-"
TARGET=${IMAGE_NAME:${#PREFIX}}

# Compile
buildtools/docker/run.sh "$CONTAINER_NAME" "CMAKE_FLAGS=\"$CMAKE_FLAGS\" /src/buildtools/scripts/configure.sh" "$TARGET"
buildtools/docker/run.sh "$CONTAINER_NAME" /src/buildtools/scripts/make.sh
if [[ $IMAGE_NAME != ubuntu-mingw-* ]]; then
	buildtools/docker/run.sh "$CONTAINER_NAME" /src/buildtools/scripts/make.sh tests
	buildtools/docker/run.sh "$CONTAINER_NAME" /build/tests/tests
fi

# Deploying MinGW only works with Ubuntu 14.04
if [[ $IMAGE_NAME == ubuntu-linux-* || $IMAGE_TAG == "14.04" ]]; then
	buildtools/docker/run.sh "$CONTAINER_NAME" /src/buildtools/scripts/package.sh "$TARGET"
fi

if [ "$CIRCLECI" ]; then
	# Copy artifacts
	docker cp "$CONTAINER_NAME":/build/ "$BUILD_DIR"
fi
