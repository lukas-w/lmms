#!/usr/bin/env bash
export SCRIPT="$0"
export DIR=$(dirname "$0")
source "$DIR/detail/common-build.sh"
set -e

SYSTEM=$(uname -s)

TARGET=$1

if [[ "$SYSTEM" == "Linux" ]]; then
	DISTRO=$(lsb_release -is)
	DISTRO_VER=$(lsb_release -rs)

	if [[ "$DISTRO" == "Ubuntu" ]]; then
		if [[ "$TARGET" ]]; then
			if [[ "$TARGET" == "win32" ]]; then
				IMAGE="ubuntu-mingw-w32"
			elif [[ "$TARGET" == "win64" ]]; then
				IMAGE="ubuntu-mingw-w64"
			else
				fatal Unknown target "$TARGET"
			fi
		else
			IMAGE="ubuntu-linux-gcc"
		fi

		repos=""
		packages=""
		for parent_img in $(parentimages $IMAGE); do
			repos="${repos}"$'\n'$("$DIR/detail/repos.sh" $parent_img $DISTRO_VER)
			packages="$packages $("$DIR/detail/packages.sh" $IMAGE $DISTRO_VER)"
		done

		repos=$(echo $repos | sed '/^\s*$/d')

		if [[ "$repos" ]]; then
			info "Need to add 3rd-party repositories to install all dependencies. I will run the following commands:"
			while read line ; do
				info "    $line"
			done < <(echo "$repos")
			if ! confirm "Continue? [y/N]:" n; then
				exit 1
			fi

			eval "$repos"
		fi

		pkg_statuses=$(dpkg-query -W --showformat='${binary:Package} ${Status}\n' $packages 2>/dev/null || true)
		installed_pkgs=""
		while read line ; do
			if [[ "$line" = *"install ok installed"* ]]; then
				pkg_name=$(echo "$line" | awk '{print $1;}')
				pkg_name=${pkg_name%:amd64} # Remove :amd64 suffix
				installed_pkgs="$installed_pkgs $pkg_name"
			fi
		done < <(echo "$pkg_statuses")
		installed_pkgs=$(echo $installed_pkgs | xargs -n1 | sort -u)
		packages=$(echo $packages | xargs -n1 | sort -u)
		missing=$(comm -13 <(echo "$installed_pkgs") <(echo "$packages") )

		if [[ "$missing" ]]; then
			info -n "Installing $(echo $missing | xargs). "
			if ! confirm "Continue? [Y/n]:" y; then
				exit 1
			fi
		else
			info "All dependencies already installed."
			exit
		fi

		sudo apt-get install $missing
	else
		fatal "Your linux distribution is not supported"
	fi
elif [[ "$SYSTEM" == "Darwin" ]]; then
	PACKAGES="cmake pkg-config libogg libvorbis lame libsndfile libsamplerate jack sdl libgig libsoundio stk portaudio node fltk qt5"

	if "${TRAVIS}"; then
	   PACKAGES="$PACKAGES ccache"
	fi

	# removing already installed packages from the list
	for p in $(brew list); do
		PACKAGES=${PACKAGES//$p/}
	done;

	# shellcheck disable=SC2086
	brew install $PACKAGES

	# fftw tries to install gcc which conflicts with travis
	brew install fftw --ignore-dependencies

	# Recompile fluid-synth without CoreAudio per issues #649
	# Ruby formula must be a URL
	brew install --build-from-source "https://gist.githubusercontent.com/tresf/c9260c43270abd4ce66ff40359588435/raw/fluid-synth.rb"

	sudo npm install -g appdmg
else
	fatal "Your operating system is not supported"
fi
