#!/usr/bin/env bash
set -Eeuxo pipefail

# htop
# https://hisham.hm/htop/releases/
# https://github.com/hishamhm/htop

build_dir="${HOME}/build/htop"
version="2.2.0"
prefix="/usr/local"

# Check for RedHat.
if [[ ! -f "/etc/redhat-release" ]]
then
    echo "Error: RedHat Linux is required." >&2
    exit 1
fi

# Error on conda detection.
# Can conflict with ncurses: libncursesw.so.6
if [[ -x "$(command -v conda)" ]] && [[ -n "${CONDA_PREFIX:-}" ]]
then
    echo "Error: conda is active." >&2
    exit 1
fi

echo "Installing htop ${version}."
echo "sudo is required for this script."
sudo -v

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    mkdir -p "$build_dir"
    cd "$build_dir" || return 1
    wget "https://hisham.hm/htop/releases/${version}/htop-${version}.tar.gz"
    tar -xzvf "htop-${version}.tar.gz"
    cd "htop-${version}" || return 1
    ./configure --prefix="$prefix"
    make
    make check
    sudo make install
)

# Ensure ldconfig is current.
sudo ldconfig

echo "htop installed successfully."
command -v htop
htop --version

unset -v build_dir prefix version
