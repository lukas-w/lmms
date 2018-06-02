#!/usr/bin/env bash
set -e

SYSTEM=$1
VER=$2

# swh build dependencies
PACKAGES_SWH="
	liblist-moreutils-perl
	libxml-perl
	libxml2-utils
	perl
"

if [ $SYSTEM == "ubuntu" ]; then
	PACKAGES="
		$PACKAGES_SWH
		ca-certificates
		git
		libc6-dev
		make
		perl
		ssh-client
		qttools5-dev-tools
		qt5-default
	"

	# On Ubuntu 14.04 Qt5LinguistToolsConfig.cmake is provided by qttools5-dev, in
	# later versions it was moved to qttools5-dev-tools. lupdate itself is always
	# provided by qttools5-dev-tools
	if [ "$VER" == "14.04" ]; then  \
		PACKAGES="$PACKAGES
			cmake3
			qt59tools
		"
	else
		PACKAGES="$PACKAGES
			cmake
		"
	fi
elif [ $SYSTEM == "ubuntu-linux" ]; then
	PACKAGES="
		g++-multilib
		gcc-multilib
		libasound2-dev
		libfftw3-dev
		libfltk1.3-dev
		libfluidsynth-dev
		libgig-dev
		libmp3lame-dev
		libjack-jackd2-dev
		libogg-dev
		libsamplerate0-dev
		libsdl1.2-dev
		libsndfile1-dev
		libsoundio-dev
		libstk0-dev
		libvorbis-dev
		portaudio19-dev
		stk
	"

	if [ "$VER" == "14.04" ]; then
		PACKAGES_QT="
			qt59base
			qt59tools
			qt59translations
		"
	else
		PACKAGES="
			$PACKAGES
			fluid
			libc6-dev-i386
			libxft-dev
			libxinerama-dev
		"
		PACKAGES_QT="
			qtbase5-dev
		"
	fi

	# VST dependencies
	PACKAGES_VST="
		$PACKAGES_VST
		libxcb-keysyms1-dev
		libxcb-util0-dev
		qtbase5-private-dev
	"

	if [ "$VER" == "14.04" ]; then
		PACKAGES_VST="$PACKAGES_VST qt59x11extras"
	else
		PACKAGES_VST="$PACKAGES_VST libqt5x11extras5-dev"
	fi

	if [ "$VER" == "14.04" ]; then
		PACKAGES_VST="
			$PACKAGES_VST
			wine-dev
		"
	elif [ "$VER" == "16.04" ]; then
		# For some reason, apt fails installing wine1.6-dev when not explicitly
		# specifying its dependencies wine1.6 and binfmt-support
		PACKAGES_VST="
			$PACKAGES_VST
			libwine-development
			libwine-development:i386
			wine64-development-tools
		"
	elif [[ "$VER" == "18.04" ]]; then
		PACKAGES_VST="
			$PACKAGES_VST
			libwine-dev
			libwine-dev:i386
			wine64-tools
		"
	fi

	PACKAGES="$PACKAGES $PACKAGES_VST $PACKAGES_QT"
elif [ $SYSTEM == "ubuntu-linux-gcc" ]; then
	PACKAGES="$PACKAGES
		stk wget file
	"
elif [[ "$SYSTEM" == "ubuntu-mingw"* ]]; then
	PACKAGES="
		nsis cloog-isl libmpc3
	"
	if [ "$VER" == "14.04" ]; then
		PACKAGES="
			$PACKAGES mingw32-x-qt5base mingw32-x-gcc mingw32-x-runtime
		"
		if [[ "$SYSTEM" == "ubuntu-mingw-w32" ]]; then
			PACKAGES="$PACKAGES
				mingw32-x-sdl mingw32-x-libvorbis mingw32-x-fluidsynth mingw32-x-stk
				mingw32-x-glib2 mingw32-x-portaudio mingw32-x-libsndfile mingw32-x-fftw
				mingw32-x-flac mingw32-x-fltk mingw32-x-libsamplerate
				mingw32-x-pkgconfig mingw32-x-binutils
				mingw32-x-libgig mingw32-x-libsoundio mingw32-x-lame
			"
		elif [[ "$SYSTEM" == "ubuntu-mingw-w64" ]]; then
			PACKAGES="$PACKAGES
				mingw64-x-sdl mingw64-x-libvorbis mingw64-x-fluidsynth mingw64-x-stk
				mingw64-x-glib2 mingw64-x-portaudio mingw64-x-libsndfile
				mingw64-x-fftw mingw64-x-flac mingw64-x-fltk mingw64-x-libsamplerate
				mingw64-x-pkgconfig mingw64-x-binutils mingw64-x-gcc mingw64-x-runtime
				mingw64-x-libgig mingw64-x-libsoundio mingw64-x-lame mingw64-x-qt5base
			"
		fi
	elif [[ "$SYSTEM" = "ubuntu-mingw" ]]; then
		PACKAGES="
			$PACKAGES
			mingw-w64
			mingw-w64-tools
			binutils-mingw-w64
			fftw-mingw-w64
			flac-mingw-w64
			fltk-mingw-w64
			fluidsynth-mingw-w64
			gcc-mingw-w64
			glib2-mingw-w64
			lame-mingw-w64
			libgig-mingw-w64
			libsamplerate-mingw-w64
			libsndfile-mingw-w64
			libsoundio-mingw-w64
			libvorbis-mingw-w64
			libz-mingw-w64-dev
			portaudio-mingw-w64
			qt5base-mingw-w64
			sdl-mingw-w64
			stk-mingw-w64
		"
	fi
elif [[ "$SYSTEM" == "macos" ]]; then
	PACKAGES="
		cmake
		pkg-config
		libogg
		libvorbis
		lame
		libsndfile
		libsamplerate
		jack
		sdl
		libgig
		libsoundio
		stk
		portaudio
		node
		fltk
		qt5
	"
else
	>&2 echo "Unknown system $SYSTEM"
	exit 1
fi

echo $PACKAGES | xargs -n1 | sort -u
