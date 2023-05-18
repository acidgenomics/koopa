#!/usr/bin/env bash

koopa_linux_locate_bcbio_python() {
    koopa_locate_app \
        --app-name='bcbio-nextgen' \
        --bin-name='bcbio_python' \
        "$@"
}
