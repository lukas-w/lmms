#!/usr/bin/env bash
set -e

CMAKE_FLAGS="$CMAKE_FLAGS -DUSE_WERROR=OFF"
export CMAKE_FLAGS

buildtools/scripts/configure.sh
buildtools/scripts/make.sh

buildtools/scripts/make.sh tests
build/tests/tests

buildtools/scripts/package.sh
