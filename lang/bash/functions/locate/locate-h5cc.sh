#!/usr/bin/env bash

_koopa_locate_h5cc() {
    _koopa_locate_app \
        --app-name='hdf5' \
        --bin-name='h5cc' \
        "$@"
}
