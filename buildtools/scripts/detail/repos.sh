#!/usr/bin/env bash
set -e
SYSTEM=$1
VER=$2
DOCKER=$3

function has_repo {
	if [[ "$DOCKER" ]]; then
		return 1
	fi
	local policy=$(apt-cache policy)
	if ! grep -q "$1" <<< $policy; then
		return 1
	fi
}

function add_ppa {
	if ! has_repo "$1"; then
		echo add-apt-repository ppa:$1 -y
		return 0
	else
		return 1
	fi
}

if [[ "$SYSTEM" == "ubuntu" ]]; then
	if [[ "$VER" == "14.04" ]]; then
		add_ppa "beineri/opt-qt592-trusty"
	fi
elif [[ "$SYSTEM" == "ubuntu-linux" ]]; then
	if [[ "$DOCKER" || ! $(dpkg --print-foreign-architectures) = *"i386"* ]]; then
		echo dpkg --add-architecture i386
	fi
	if [[ "$VER" == "14.04" ]]; then
		# For libsoundio
		if add_ppa "andrewrk/libgroove"; then
			echo sed -e "s/trusty/precise/" -i /etc/apt/sources.list.d/andrewrk-libgroove-trusty.list
		fi
	fi
elif [[ "$SYSTEM" == "ubuntu-linux-gcc" ]]; then
	exit
elif [[ "$SYSTEM" = "ubuntu-mingw" ]]; then
	if [ "$VER" == "14.04" ]; then
		add_ppa tobydox/mingw-x-trusty -y
	else
		if ! has_repo "tobydox/mingw-w64"; then
			echo "echo "deb http://ppa.launchpad.net/tobydox/mingw-w64/ubuntu artful main" >> /etc/apt/sources.list"
			echo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 72931B477E22FEFD47F8DECE02FE5F12ADDE29B2
		fi
	fi
elif [[ "$SYSTEM" = "ubuntu-mingw-w32" ]]; then
	exit
elif [[ "$SYSTEM" = "ubuntu-mingw-w64" ]]; then
	exit
else
	>&2 echo "Unknown system $SYSTEM"
	exit 1
fi
