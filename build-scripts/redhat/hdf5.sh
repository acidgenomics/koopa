#!/usr/bin/env bash
set -Eeuxo pipefail

# HDF5
# Website requires registration.
# https://www.hdfgroup.org/downloads/hdf5/
# https://support.hdfgroup.org/ftp/HDF5/releases

build_dir="/tmp/build/hdf5"
prefix="/usr/local"
hdf5_major="1.10"
hdf5_version="${hdf5_major}.5"

echo "Installing HDF5 ${hdf5_version}."

# Run preflight initialization checks.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=/dev/null
. "${script_dir}/_init.sh"

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir" || return 1
    wget "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${hdf5_major}/hdf5-${hdf5_version}/src/hdf5-${hdf5_version}.tar.gz"
    tar -xzvf "hdf5-${hdf5_version}.tar.gz"
    cd "hdf5-${hdf5_version}" || return 1
    ./configure \
        --prefix="$prefix" \
        --enable-cxx \
        --enable-fortran
    make
    make check
    sudo make install
    rm -rf "$build_dir"
)

# Ensure ldconfig is current.
sudo ldconfig

echo "hdf5 installed successfully."
command -v h5dump
h5dump --version
