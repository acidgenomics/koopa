#!/usr/bin/env bash
set -Eeuxo pipefail

# Emacs text editor
# https://www.gnu.org/software/emacs/
#
# See also:
# - https://github.com/emacs-mirror/emacs

build_dir="/tmp/build/emacs"
prefix="/usr/local"
version="26.2"

echo "Installing emacs ${version}."

# Run preflight initialization checks.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=/dev/null
. "${script_dir}/_init.sh"

# Install build dependencies.
sudo yum-builddep -y emacs

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir" || return 1
    wget "http://ftp.gnu.org/gnu/emacs/emacs-${version}.tar.xz"
    tar -xJvf "emacs-${version}.tar.xz"
    cd "emacs-${version}" || return 1
    ./configure --prefix="$prefix"
    make
    sudo make install
    rm -rf "$build_dir"
)

# Ensure ldconfig is current.
sudo ldconfig

echo "emacs installed successfully."
command -v emacs
emacs --version
