#!/usr/bin/env bash
set -e

if [ -z "$UBUNTU_VERSION" ]; then
    UBUNTU_VERSION=$(lsb_release -rs)
fi

apt-get update
apt-get install -y --no-install-recommends $PACKAGES

rm -rf /var/lib/apt/lists/*
