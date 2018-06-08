#!/usr/bin/env bash
set -e
export SCRIPT="$0"
export DIR=$(dirname "$0")
source "$DIR/../scripts/detail/common-build.sh"

IMAGE_NAME=$1
VERSION=$2
TAG=$VERSION-$GIT_BRANCH

if [[ "$VERBOSE" ]]; then
	ERR=/dev/stderr
	OUT=/dev/stdout
else
	ERR=/dev/null
	OUT=/dev/null
fi

if [ -z "$IMAGE_USER" ]; then
	IMAGE_USER=lmmsci
fi

function pull() {
	local IMAGE_NAME=$1
	local IMAGE=$IMAGE_USER/$IMAGE_PREFIX$IMAGE_NAME

	if [[ "$(docker images -q $IMAGE:$TAG 2> /dev/null)" == "" ]]; then
		info "Trying to pull $IMAGE:$TAG"
		if docker pull $IMAGE:$TAG; then
			info "Download succeeded"
		else
			info "Download failed"
		fi
	fi

	if [[ "$(docker images -q $IMAGE:$TAG 2> /dev/null)" == "" ]]; then
		info "No image found, building without cache"
	else
		info "Using --cache-from $IMAGE:$TAG"
		CACHE_FROM="$CACHE_FROM --cache-from $IMAGE:$TAG"
	fi
}

function build() {
	local IMAGE_NAME=$1
	local DOCKERFILE=$1
	local TAG=$2
	local IMAGE=$IMAGE_USER/$IMAGE_PREFIX$IMAGE_NAME


	info "Generating build scripts"
	mkdir -p "$DIR"/Dockerfiles/tmp/
	"$DIR"/../scripts/detail/repos.sh $IMAGE_NAME $VERSION docker > "$DIR"/Dockerfiles/tmp/$IMAGE_NAME.repos
	"$DIR"/../scripts/detail/packages.sh $IMAGE_NAME $VERSION docker > "$DIR"/Dockerfiles/tmp/$IMAGE_NAME.packages

	if [[ "$IMAGE_NAME" == ubuntu ]]; then
		DOCKER_ARGS="$DOCKER_ARGS --build-arg UBUNTU_VERSION=$VERSION"
	fi

	info "Building image from Dockerfile"
	docker build                          \
	    --tag $IMAGE:$TAG                 \
	    $CACHE_FROM                       \
	    $DOCKER_ARGS                      \
	    -f "$DIR/Dockerfiles/$DOCKERFILE" \
	    "$DIR/Dockerfiles"


	# Push to Docker hub
	if [[ "$CI" ]] && [[ "$DOCKER_PASS" ]]; then
		info "Logging in to Docker"
		docker login -u "$DOCKER_USER" -p "$DOCKER_PASS"

		info "Pushing image"
		docker push "$IMAGE:$TAG"
	fi
}

for parent_img in $(parentimages $IMAGE_NAME); do
	pull $parent_img
done

if [[ "$IMAGE_NAME" == ubuntu* ]]; then
	DOCKER_ARGS="$DOCKER_ARGS --build-arg TAG=$TAG"
fi

for parent_img in $(parentimages $IMAGE_NAME); do
	info "Building image $parent_img:$TAG"
	DOCKER_ARGS=$DOCKER_ARGS build $parent_img $TAG
done
