#!/usr/bin/env bash
set -Eeuxo pipefail

# Tmux terminal multiplexer
# https://github.com/tmux/tmux

build_dir="${HOME}/build/tmux"
prefix="/usr/local"
version="2.8"

# Check for RedHat.
if [[ ! -f "/etc/redhat-release" ]]
then
    echo "Error: RedHat Linux is required." >&2
    exit 1
fi

# Error on conda detection.
if [ -x "$(command -v conda)" ]
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

echo "Installing tmux ${version}."
echo "sudo is required for this script."
sudo -v

# Build dependencies.
sudo yum -y install yum-utils
sudo yum-builddep -y tmux

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    mkdir -p "$build_dir"
    cd "$build_dir" || return 1
    wget "https://github.com/tmux/tmux/releases/download/${version}/tmux-${version}.tar.gz"
    tar -xzvf "tmux-${version}.tar.gz"
    cd "tmux-${version}" || return 1
    ./configure --prefix="$prefix"
    make
    sudo make install
)

# Ensure ldconfig is current.
sudo ldconfig

echo "tmux installed successfully."
command -v tmux
tmux -V

unset -v build_dir prefix version
