#!/usr/bin/env bash
set -Eeuxo pipefail

# Vim
# https://github.com/vim/vim

build_dir="/tmp/build/vim"
prefix="/usr/local"
version="8.1.1310"

echo "Installing vim ${version}."

# Run preflight initialization checks.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
. "${script_dir}/_init.sh"

# Install build dependencies.
sudo yum-builddep -y vim

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir" || return 1
    wget "https://github.com/vim/vim/archive/v${version}.tar.gz"
    tar -xzvf "v${version}.tar.gz"
    cd "vim-${version}" || return 1
    ./configure --prefix="$prefix"
    make
    # Skip the unit tests on RedHat. It will install successfully.
    # make test
    sudo make install
    rm -rf "$build_dir"
)

# Ensure ldconfig is current.
sudo ldconfig

command -v vim
vim --version
