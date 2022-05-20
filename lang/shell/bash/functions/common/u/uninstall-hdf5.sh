#!/usr/bin/env bash

koopa_uninstall_hdf5() {
    koopa_uninstall_app \
        --name-fancy='HDF5' \
        --name='hdf5' \
        "$@"
}
