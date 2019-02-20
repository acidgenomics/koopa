#!/bin/sh

# HDF5
# Website requires registration.
# https://www.hdfgroup.org/downloads/hdf5/
# https://support.hdfgroup.org/ftp/HDF5/releases

# Error on conda detection.
if [ -x "$(command -v conda)" ]
then
    echo "Error: conda is active." >&2
    exit 1
fi

sudo -v

PREFIX="/usr/local"
HDF5_MAJOR="1.10"
HDF5_VERSION="${HDF5_MAJOR}.4"

wget "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${HDF5_MAJOR}/hdf5-${HDF5_VERSION}/src/hdf5-${HDF5_VERSION}.tar.gz"
tar -xzvf "hdf5-${HDF5_VERSION}.tar.gz"
cd "hdf5-${HDF5_VERSION}" || return 1

./configure --prefix="$PREFIX" --enable-fortran --enable-cxx

make
make check
sudo make install

h5dump --version
