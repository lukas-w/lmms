#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive

dpkg --add-architecture i386
apt-get update -qq

apt-get install -y software-properties-common

if [ -z "$UBUNTU_VERSION" ]; then
    UBUNTU_VERSION=$(lsb_release -rs)
fi

# shellcheck disable=SC2086
apt-get install -y $PACKAGES

# kxstudio repo offers Carla; avoid package conflicts (wine, etc) by running last
if [ "$UBUNTU_VERSION" == "14.04" ]; then
	add-apt-repository -y ppa:kxstudio-debian/libs
	add-apt-repository -y ppa:kxstudio-debian/apps
	apt-get update -qq
	apt-get install -y carla-git
fi
