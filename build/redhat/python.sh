#!/usr/bin/env bash
set -Eeuo pipefail

# Python
# https://www.python.org/

build_dir="${HOME}/build/python"
prefix="/usr/local"
version="3.7.3"

# Error on conda detection.
if [ -x "$(command -v conda)" ]
then
    echo "Error: conda is active." >&2
    exit 1
fi

echo "Installing python ${version}."
echo "sudo is required for this script."
sudo -v

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    mkdir -p "$build_dir"
    cd "$build_dir"
    wget "https://www.python.org/ftp/python/${version}/Python-${version}.tar.xz"
    tar xfv "Python-${version}.tar.xz"
    cd "Python-${version}"
    ./configure --prefix="$prefix" --enable-optimizations
    make
    sudo make install
)

echo "python installed correctly."
command -v python3
python3 --version

unset -v build_dir prefix version
