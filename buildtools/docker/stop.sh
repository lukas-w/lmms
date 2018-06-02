#!/usr/bin/env bash
set -e
export SCRIPT="$0"
export DIR=$(dirname "$0")
source "$DIR/../scripts/detail/common.sh"

CONTAINER_NAME=$1

docker stop -t 2 $CONTAINER_NAME
docker rm $CONTAINER_NAME