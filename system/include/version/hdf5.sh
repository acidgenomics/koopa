#!/bin/sh

## Debian: `dpkg -s libhdf5-dev`

h5cc -showconfig \
    | grep 'HDF5 Version:' \
    | sed -E 's/^(.+): //'
