#!/usr/bin/env bash
set -Eeuxo pipefail

# Python
# https://www.python.org/

build_dir="/tmp/build/python"
prefix="/usr/local"
version="3.7.3"

echo "Installing python ${version}."

# Run preflight initialization checks.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
. "${script_dir}/_init.sh"

# Install build dependencies.
sudo yum-builddep -y python

mkdir "$build_dir"

# Ensure pip is installed and up to date.
(
    cd "$build_dir"
    wget https://bootstrap.pypa.io/get-pip.py
    sudo python get-pip.py
)

# Build and install from source.
(
    cd "$build_dir"
    wget "https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz"
    tar xfv "Python-${version}.tar.xz"
    cd "Python-${version}"
    ./configure --prefix="$prefix" --enable-optimizations --enable-shared
    make
    sudo make install
)

rm -rf "$build_dir"

# Ensure ldconfig is current.
# Otherwise you can run into libpython detection errors.
sudo ldconfig

echo "python installed correctly."
command -v python3
python3 --version
