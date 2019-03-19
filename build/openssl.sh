#!/usr/bin/env bash
set -Eeuo pipefail

# Install latest OpenSSL stable release.
# https://www.openssl.org/source/
# Note that conda currently installs previous v1.0.2 LTS.

date="2019-02-26"
version="1.1.1b"

# FIXME Currently this is configured for macOS.
# Need to revise to build on Linux as well.

echo "Installing openssl ${version} (${date})."
echo "sudo is required for this script"
sudo -v

curl -O "https://www.openssl.org/source/openssl-${version}.tar.gz"
tar -xvzf "openssl-${version}.tar.gz"

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    cd "openssl-${version}" || exit 1
    ./Configure darwin64-x86_64-cc
    make
    make test
    sudo make install
)

unset -v date version

cat << EOF
openssl installed successfully.
Reload the shell and check version.
which openssl
openssl version
EOF
