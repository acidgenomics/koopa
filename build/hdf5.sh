#!/bin/sh

# HDF5
# Website requires registration.
# https://www.hdfgroup.org/downloads/hdf5/
# https://support.hdfgroup.org/ftp/HDF5/releases

sudo -v
PREFIX="/usr/local"
HDF5_MAJOR="1.10"
HDF5_VERSION="${HDF5_MAJOR}.4"

wget "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${HDF5_MAJOR}/hdf5-${HDF5_VERSION}/src/hdf5-${HDF5_VERSION}.tar.gz"
tar -xzvf "hdf5-${HDF5_VERSION}.tar.gz"
cd "hdf5-${HDF5_VERSION}"

./configure --prefix="$PREFIX" --enable-fortran --enable-cxx

make
make check
sudo make install

# Confirm the installation worked.
which h5dump
h5dump --version
