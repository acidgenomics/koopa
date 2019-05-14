#!/usr/bin/env bash
set -Eeuxo pipefail

# GNU core utilities
# https://ftp.gnu.org/gnu/coreutils/

build_dir="/tmp/build/coreutils"
prefix="/usr/local"
version="8.31"

# Check for RedHat.
if [[ ! -f "/etc/redhat-release" ]]
then
    echo "Error: RedHat Linux is required." >&2
    exit 1
fi

# Error on conda detection.
if [[ -x "$(command -v conda)" ]] && [[ -n "${CONDA_PREFIX:-}" ]]
then
    echo "Error: conda is active." >&2
    exit 1
fi

# Require yum to build dependencies.
if [[ ! -x "$(command -v yum)" ]]
then
    echo "Error: yum is required to build dependencies." >&2
    exit 1
fi

echo "Installing git ${version}."
echo "sudo is required for this script."
sudo -v

# Install dependencies.
sudo yum install -y yum-utils
sudo yum-builddep -y coreutils

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir" || return 1
    wget "https://ftp.gnu.org/gnu/coreutils/coreutils-${version}.tar.xz"
    tar -xJvf "coreutils-${version}.tar.xz"
    cd "coreutils-${version}" || return 1
    ./configure \
        --build="x86_64-redhat-linux-gnu" \
        --prefix="$prefix"
    make
    make check
    sudo make install
    rm -rf "$build_dir"
)

cat << EOF
coreutils installed successfully.
Check version with 'info coreutils'.

Patching `/usr/bin/env` is currently necessary on RHEL 7.
Run this command to use newer 'env' from coreutils:

    sudo mv /usr/bin/env /usr/bin/env.bak; \
    sudo ln -s /usr/local/bin/env /usr/bin/env

EOF
