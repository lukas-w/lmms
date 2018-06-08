#!/usr/bin/env bash
set -eo pipefail
export SCRIPT="$0"
DIR=$(dirname "$SCRIPT")
# shellcheck source=buildtools/scripts/detail/common-build.sh
source "$DIR/../buildtools/scripts/detail/common-build.sh"

# Starting local registry
DOCKER_CACHE_DIR=$HOME/docker-cache
docker run -d -p 5000:5000 --name registry -v "$DOCKER_CACHE_DIR":/var/lib/registry registry:2

#TAG=$TAG
IMAGE_USER=localhost:5000
IMAGE="$IMAGE_USER/$IMAGE_NAME:$TAG"

# Load Docker cache
info "Reading image $IMAGE from Travis cache"
if docker pull "$IMAGE"; then
	docker tag "$IMAGE" "lmmsci/$IMAGE_NAME:$TAG"
	info "Pulled from local registry"
else
	info "Pulling from local registry failed"
fi

buildtools/docker/build-image.sh "$IMAGE_NAME" "$TAG" "$TAG"

# Save Docker cache
mkdir -p "$DOCKER_CACHE_DIR"
info "Pushing $IMAGE to local registry"
# Push to local cache registry
docker tag "lmmsci/$IMAGE_NAME:$TAG" "$IMAGE"
docker push "$IMAGE"
#rm "$DOCKER_CACHE_DIR"/*
#time (docker save "lmmsci/$IMAGE_NAME:$TAG" | tar x -C "$DOCKER_CACHE_DIR")

# Push to Docker hub on master
if [[ "$DOCKER_PASS" && "$TRAVIS_BRANCH" == "master" ]]; then
	info "Logging in to Docker"
	docker login -u "$DOCKER_USER" -p "$DOCKER_PASS"

	info "Pushing image"
	docker push "$IMAGE_NAME":"$TAG"
fi
