#!/usr/bin/env bash
set -Eeuxo pipefail

# OpenSSL
# https://www.openssl.org/source/

build_dir="/tmp/openssl"
date="2019-02-26"
version="1.1.1b"
prefix="/usr/local"

# Check for RedHat.
if [[ ! -f "/etc/redhat-release" ]]
then
    echo "Error: RedHat Linux is required." >&2
    exit 1
fi

echo "Installing openssl ${version} (${date})."
echo "sudo is required for this script."
sudo -v

# Install dependencies.
sudo yum -y install yum-utils
sudo yum-builddep -y openssl

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    mkdir -p "$build_dir"
    cd "$build_dir" || exit 1
    curl -O "https://www.openssl.org/source/openssl-${version}.tar.gz"
    tar -xvzf "openssl-${version}.tar.gz"
    cd "openssl-${version}" || exit 1
    ./config --prefix="$prefix"
    make
    make test
    sudo make install
)

echo "Updating ldconfig."
sudo ldconfig

cat << EOF
openssl installed successfully.
Reload the shell and check version.

command -v openssl
openssl version
EOF
