#!/usr/bin/env bash
set -e
set -o pipefail
export SCRIPT="$0"
DIR=$(dirname "$SCRIPT")
# shellcheck source=buildtools/scripts/detail/common-build.sh
source "$DIR/../buildtools/scripts/detail/common-build.sh"

# Load Docker cache
DOCKER_CACHE_DIR=$HOME/docker-cache
DOCKER_CACHE_FILE=$DOCKER_CACHE_DIR/image.tar
if [[ -e "$DOCKER_CACHE_FILE" ]]; then
	info "Reading image from Travis cache"
	time (docker load < "$DOCKER_CACHE_FILE")
fi

buildtools/docker/build-image.sh "$IMAGE_NAME" "$TAG"

TAG=$TAG-$TRAVIS_BRANCH

# Save Docker cache
mkdir -p "$DOCKER_CACHE_DIR"
info "Saving image to Travis cache"
time (docker save "lmmsci/$IMAGE_NAME:$TAG" > "$DOCKER_CACHE_FILE")

# Push to Docker hub on master
if [[ "$DOCKER_PASS" && "$TRAVIS_BRANCH" == "master" ]]; then
	info "Logging in to Docker"
	docker login -u "$DOCKER_USER" -p "$DOCKER_PASS"

	info "Pushing image"
	docker push "$IMAGE_NAME":"$TAG"
fi
