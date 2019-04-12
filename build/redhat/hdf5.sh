#!/usr/bin/env bash
set -Eeuxo pipefail

# HDF5
# Website requires registration.
# https://www.hdfgroup.org/downloads/hdf5/
# https://support.hdfgroup.org/ftp/HDF5/releases

build_dir="${HOME}/build/hdf5"
prefix="/usr/local"
hdf5_major="1.10"
hdf5_version="${hdf5_major}.4"

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

echo "Installing HDF5 ${version}."
echo "sudo is required for this script."
sudo -v

# SC2103: Use a ( subshell ) to avoid having to cd back.
(
    mkdir -p "$build_dir"
    cd "$build_dir" || return 1
    wget "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${hdf5_major}/hdf5-${hdf5_version}/src/hdf5-${hdf5_version}.tar.gz"
    tar -xzvf "hdf5-${hdf5_version}.tar.gz"
    cd "hdf5-${hdf5_version}" || return 1
    ./configure --prefix="$prefix" --enable-fortran --enable-cxx
    make
    make check
    sudo make install
)

# Ensure ldconfig is current.
sudo ldconfig

echo "hdf5 installed successfully."
command -v h5dump
h5dump --version

unset -v build_dir hdf5_major hdf5_version prefix
