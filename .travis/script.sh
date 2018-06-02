#!/usr/bin/env bash
set -e

if [ "$TYPE" = 'style' ]; then

	# SC2185 is disabled because of: https://github.com/koalaman/shellcheck/issues/942
	# once it's fixed, it should be enabled again
	# shellcheck disable=SC2185
	# shellcheck disable=SC2046
	shellcheck $(find -O3 "$TRAVIS_BUILD_DIR/.travis/" "$TRAVIS_BUILD_DIR/cmake/" -type f -name '*.sh' -o -name "*.sh.in")

else
	mkdir -p build

	export CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=RelWithDebInfo"

	if [ -z "$TRAVIS_TAG" ]; then
		export CMAKE_FLAGS="$CMAKE_FLAGS -DUSE_CCACHE=ON"
	fi

	"$TRAVIS_BUILD_DIR/.travis/$TRAVIS_OS_NAME.script.sh"

	# Package and upload non-tagged builds
	if [ ! -z "$TRAVIS_TAG" ]; then
		# Skip, handled by travis deploy instead
		exit 0
	elif [[ $IMAGE_NAME == ubuntu-mingw-* ]]; then
		if [[ $TAG != "14.04" ]]; then
			# Skip, broken
			exit 0
		fi
		PACKAGE="$(ls build/lmms-*win*.exe)"
	elif [[ $TRAVIS_OS_NAME == osx ]]; then
		PACKAGE="$(ls build/lmms-*.dmg)"
	else
		PACKAGE="$(ls build/lmms-*.AppImage)"
	fi

	echo "Uploading $PACKAGE to transfer.sh..."
	curl --upload-file "$PACKAGE" "https://transfer.sh/$PACKAGE" || true
fi
