#!/usr/bin/env bash
set -Eeuxo pipefail

# Emacs text editor
# - https://www.gnu.org/software/emacs/index.html#Releases
# - https://github.com/emacs-mirror/emacs

build_dir="${HOME}/build/emacs"
prefix="/usr/local"
version="26.1"

# Check for RedHat.
if [[ ! -f "/etc/redhat-release" ]]
then
    echo "Error: RedHat Linux is required." >&2
    exit 1
fi

# Error on conda detection.
if [[ -x "$(command -v conda)" ]]
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

echo "Installing emacs ${version}."
echo "sudo is required for this script."
sudo -v

sudo yum -y install yum-utils
sudo yum-builddep -y emacs

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    mkdir -p "$build_dir"
    cd "$build_dir" || return 1
    wget "http://ftp.gnu.org/gnu/emacs/emacs-${version}.tar.xz"
    tar -xJvf "emacs-${version}.tar.xz"
    cd "emacs-${version}" || return 1
    ./configure --prefix="$prefix"
    make
    sudo make install
)

# Ensure ldconfig is current.
sudo ldconfig

echo "emacs installed successfully."
command -v emacs
emacs --version

unset -v build_dir prefix version
