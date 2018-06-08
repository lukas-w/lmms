#!/usr/bin/env bash
set -eo pipefail
export SCRIPT="$0"
DIR=$(dirname "$SCRIPT")
# shellcheck source=buildtools/scripts/detail/common-build.sh
source "$DIR/../buildtools/scripts/detail/common-build.sh"

buildtools/docker/build-image.sh "$IMAGE_NAME" "$IMAGE_TAG"
TAG=$IMAGE_TAG-$GIT_BRANCH
docker tag "lmmsci/$IMAGE_NAME:$TAG" "ci-image"
