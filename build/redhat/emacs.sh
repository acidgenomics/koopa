#!/usr/bin/env bash
set -Eeuxo pipefail

# Emacs text editor
# - https://www.gnu.org/software/emacs/index.html#Releases
# - https://github.com/emacs-mirror/emacs

build_dir="${HOME}/build/emacs"
prefix="/usr/local"
version="26.1"

# Error on conda detection.
if [[ -x "$(command -v conda)" ]]
then
    echo "Error: conda is active." >&2
    exit 1
fi

# Build emacs dependencies with yum.
if [[ ! -x "$(command -v yum)" ]]
then
    echo "Error: yum is required to build dependencies." >&2
    exit 1
fi

echo "Installing emacs ${version}."
echo "sudo is required for this script."
sudo -v

sudo yum -y install yum-utils
sudo yum-builddep -y emacs

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    mkdir -p "$build_dir"
    cd "$build_dir"
    wget "http://ftp.gnu.org/gnu/emacs/emacs-${version}.tar.xz"
    tar -xJvf "emacs-${version}.tar.xz"
    cd "emacs-${version}" || return 1
    ./configure --prefix="$prefix"
    make
    sudo make install
)

echo "emacs installed successfully."
command -v emacs
emacs --version

unset -v build_dir prefix version
